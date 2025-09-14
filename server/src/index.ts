import 'dotenv/config';
import Fastify from 'fastify';
import cors from '@fastify/cors';
import staticFiles from '@fastify/static';
import { cleanRoutes } from './routes/clean';
import { strategyRoutes } from './routes/strategies';
import { rateLimiterService } from './middleware/rateLimiter';
import { getRateLimitConfig } from './config/rateLimit';
import { createAdminAuthMiddleware } from './middleware/adminAuth';
import path from 'path';

// Create Fastify instance early; we will either
// - export a Vercel handler that forwards requests to it, or
// - call listen() for local/dev environments.
const fastify = Fastify({
    logger: process.env.NODE_ENV === 'development' ? {
        level: process.env.LOG_LEVEL || 'info',
        transport: {
            target: 'pino-pretty',
            options: {
                colorize: true,
                translateTime: 'HH:MM:ss Z',
                ignore: 'pid,hostname,req,res',
                // Remove sensitive data from logs
                messageFormat: '{msg}',
            },
        },
        // Use serializers to safely handle request/response objects
        serializers: {
            req: (req) => ({
                method: req.method,
                url: req.url,
                headers: {
                    'user-agent': req.headers['user-agent'],
                    'content-type': req.headers['content-type'],
                },
                remoteAddress: req.ip,
            }),
            res: (res) => ({
                statusCode: res.statusCode,
            }),
        },
    } : {
        level: process.env.LOG_LEVEL || 'info',
        // In production, ensure no sensitive data is logged
        serializers: {
            req: (req) => ({
                method: req.method,
                url: req.url,
                headers: {
                    'user-agent': req.headers['user-agent'],
                    'content-type': req.headers['content-type'],
                },
                remoteAddress: req.ip,
            }),
            res: (res) => ({
                statusCode: res.statusCode,
            }),
        },
    },
});
let initialized = false;
let adminAuthOnce: ReturnType<typeof createAdminAuthMiddleware> | null = null;

async function initApp() {
    if (initialized) return;
    // Initialize admin authentication
    const adminSecret = process.env.ADMIN_SECRET;
    if (!adminSecret || adminSecret.length !== 64) {
        const msg = 'WARN: ADMIN_SECRET missing or invalid length; admin routes will require valid token and remain protected.';
        console.warn(msg);
        // Use a dummy secret so admin routes still respond with 401 instead of crashing
        adminAuthOnce = createAdminAuthMiddleware({ adminSecret: '0'.repeat(64) });
    } else {
        adminAuthOnce = createAdminAuthMiddleware({ adminSecret });
    }

    // Initialize rate limiting with configuration
    const rateLimitConfig = getRateLimitConfig();
    rateLimiterService.updateConfig(rateLimitConfig);

    // Register CORS
    await fastify.register(cors, {
        origin: true,
        credentials: true,
    });

    // Register rate limiters
    await rateLimiterService.registerRateLimiters(fastify);

    // Register static files for admin UI
    await fastify.register(staticFiles, {
        root: path.join(__dirname, 'public'),
        prefix: '/admin/',
    });

    // Add authentication middleware to admin routes
    fastify.addHook('preHandler', async (request, reply) => {
        // Only apply admin auth to /admin/* routes
        if (request.url.startsWith('/admin/') && adminAuthOnce) {
            await adminAuthOnce(request, reply);
        }
    });

    // Register API routes
    await fastify.register(cleanRoutes, { prefix: '/api' });
    await fastify.register(strategyRoutes, { prefix: '/api' });

    // Health check endpoint (non-prefixed)
    fastify.get('/health', async (_request, _reply) => {
        return { status: 'ok', timestamp: new Date().toISOString() };
    });

    // Root redirect to admin UI (protected)
    fastify.get('/', {
        preHandler: adminAuthOnce!,
    }, async (_request, reply) => {
        return reply.redirect('/admin/');
    });

    await fastify.ready();
    initialized = true;
}

async function start() {
    try {
        await initApp();

        // Start server for local/dev environments
        const port = parseInt(process.env.PORT || '3000', 10);
        const host = process.env.HOST || 'localhost';

        await fastify.listen({ port, host });
        console.log(`🚀 Server running at http://${host}:${port}`);
        console.log(`📊 Admin UI available at http://${host}:${port}/admin/`);
    } catch (err) {
        fastify.log.error(err);
        process.exit(1);
    }
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
    console.log('Received SIGINT, shutting down gracefully...');
    await rateLimiterService.close();
    await fastify.close();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    console.log('Received SIGTERM, shutting down gracefully...');
    await rateLimiterService.close();
    await fastify.close();
    process.exit(0);
});

// If running on Vercel (@vercel/node), export a handler instead of listening
// This allows the serverless function to dispatch requests to Fastify without binding a port
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export default async function handler(req: any, res: any) {
    try {
        await initApp();
        // Forward the incoming request to Fastify's underlying Node server
        fastify.server.emit('request', req, res);
    } catch (err) {
        // If initialization fails (e.g., missing ADMIN_SECRET), return 500
        res.statusCode = 500;
        res.setHeader('Content-Type', 'application/json');
        res.end(JSON.stringify({ success: false, error: 'Initialization error' }));
    }
}

// Start a real server only when not in Vercel/serverless environment
if (!process.env.VERCEL) {
    start();
}
