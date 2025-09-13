import { FastifyRequest, FastifyReply } from 'fastify';
import { createSafeLogger } from '../utils/logger';

export interface AdminAuthOptions {
    adminSecret: string;
}

export function createAdminAuthMiddleware(options: AdminAuthOptions) {
    const { adminSecret } = options;
    const safeLogger = createSafeLogger(console);

    return async function adminAuthMiddleware(request: FastifyRequest, reply: FastifyReply) {
        try {
            // Check if admin secret is configured
            if (!adminSecret || adminSecret.length !== 64) {
                safeLogger.error({
                    hasSecret: !!adminSecret,
                    secretLength: adminSecret?.length || 0
                }, 'Admin secret not properly configured');
                return reply.status(500).send({
                    success: false,
                    error: 'Admin authentication not configured',
                    timestamp: new Date().toISOString(),
                });
            }

            // Get the Authorization header
            const authHeader = request.headers.authorization;

            if (!authHeader) {
                safeLogger.warn({
                    ip: request.ip,
                    userAgent: request.headers['user-agent']
                }, 'Admin access attempted without authorization header');
                return reply.status(401).send({
                    success: false,
                    error: 'Authorization header required',
                    timestamp: new Date().toISOString(),
                });
            }

            // Check if it's a Bearer token
            if (!authHeader.startsWith('Bearer ')) {
                safeLogger.warn({
                    ip: request.ip,
                    userAgent: request.headers['user-agent'],
                    authHeader: authHeader.substring(0, 10) + '...'
                }, 'Admin access attempted with invalid authorization format');
                return reply.status(401).send({
                    success: false,
                    error: 'Invalid authorization format. Use Bearer token',
                    timestamp: new Date().toISOString(),
                });
            }

            // Extract the token
            const token = authHeader.substring(7); // Remove 'Bearer ' prefix

            // Validate the token length (should be 64 characters)
            if (token.length !== 64) {
                safeLogger.warn({
                    ip: request.ip,
                    userAgent: request.headers['user-agent'],
                    tokenLength: token.length
                }, 'Admin access attempted with invalid token length');
                return reply.status(401).send({
                    success: false,
                    error: 'Invalid token format',
                    timestamp: new Date().toISOString(),
                });
            }

            // Use constant-time comparison to prevent timing attacks
            if (!constantTimeCompare(token, adminSecret)) {
                safeLogger.warn({
                    ip: request.ip,
                    userAgent: request.headers['user-agent']
                }, 'Admin access attempted with invalid token');
                return reply.status(401).send({
                    success: false,
                    error: 'Invalid admin token',
                    timestamp: new Date().toISOString(),
                });
            }

            // Token is valid, continue to the next handler
            safeLogger.info({
                ip: request.ip,
                userAgent: request.headers['user-agent'],
                path: request.url
            }, 'Admin access granted');

        } catch (error) {
            safeLogger.error({
                error: error instanceof Error ? error.message : String(error),
                ip: request.ip
            }, 'Admin authentication error');
            return reply.status(500).send({
                success: false,
                error: 'Authentication error',
                timestamp: new Date().toISOString(),
            });
        }
    };
}

/**
 * Constant-time string comparison to prevent timing attacks
 */
function constantTimeCompare(a: string, b: string): boolean {
    if (a.length !== b.length) {
        return false;
    }

    let result = 0;
    for (let i = 0; i < a.length; i++) {
        result |= a.charCodeAt(i) ^ b.charCodeAt(i);
    }

    return result === 0;
}

/**
 * Generate a random 64-character admin secret
 * This is a utility function for generating secrets during setup
 */
export function generateAdminSecret(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < 64; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}
