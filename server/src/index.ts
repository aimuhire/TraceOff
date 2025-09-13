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

async function start() {
    try {
        // Initialize admin authentication
        const adminSecret = process.env.ADMIN_SECRET;
        if (!adminSecret || adminSecret.length !== 64) {
            console.error('ERROR: ADMIN_SECRET must be a 64-character string');
            console.error('Please set ADMIN_SECRET in your environment variables');
            process.exit(1);
        }
        const adminAuth = createAdminAuthMiddleware({ adminSecret });

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
            if (request.url.startsWith('/admin/')) {
                await adminAuth(request, reply);
            }
        });

        // Register API routes
        await fastify.register(cleanRoutes, { prefix: '/api' });
        await fastify.register(strategyRoutes, { prefix: '/api' });

        // Health check endpoint
        fastify.get('/health', async (_request, _reply) => {
            return { status: 'ok', timestamp: new Date().toISOString() };
        });

        // Root redirect to admin UI (protected)
        fastify.get('/', {
            preHandler: adminAuth,
        }, async (_request, reply) => {
            return reply.redirect('/admin/');
        });

        // Start server
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

start();
