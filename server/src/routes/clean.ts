import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { CleanRequest, CleanResult, PreviewRequest, ApiResponse } from '../types';
import { StrategyEngine } from '../engine/StrategyEngine';
import rateLimit from '@fastify/rate-limit';
import { createSafeLogger, getSafeRequestInfo } from '../utils/logger';

export async function cleanRoutes(fastify: FastifyInstance) {
    const strategyEngine = new StrategyEngine();
    const safeLogger = createSafeLogger(fastify.log);

    // Initialize with default strategies
    const { StrategyFactory } = await import('../engine/strategies');
    const strategies = StrategyFactory.createAllStrategies();
    strategies.forEach(strategy => strategyEngine.addStrategy(strategy));

    // Apply specific rate limiting for clean endpoints
    await fastify.register(rateLimit, {
        keyGenerator: (request: FastifyRequest) => {
            const ip = request.ip || 'unknown';
            const userAgent = request.headers['user-agent'] || 'unknown';
            const identifier = `${ip}:${Buffer.from(userAgent).toString('base64').slice(0, 16)}`;
            return `clean:${identifier}`;
        },
        max: parseInt(process.env.RATE_LIMIT_CLEAN_MAX || '20', 10),
        timeWindow: process.env.RATE_LIMIT_CLEAN_WINDOW || '1m',
        errorResponseBuilder: (_request: FastifyRequest, context: any) => {
            const retryAfter = Math.round(context.timeWindow / 1000);
            const limit = context.max;
            const remaining = Math.max(0, limit - context.current);

            return {
                success: false,
                error: 'Rate limit exceeded',
                message: `Too many clean requests. Limit: ${limit} requests per ${context.timeWindow}ms`,
                retryAfter,
                limit,
                remaining,
                resetTime: new Date(Date.now() + context.timeWindow).toISOString(),
                timestamp: new Date().toISOString(),
            };
        },
        skipOnError: true,
    });

    // POST /api/clean
    fastify.post<{ Body: CleanRequest }>('/clean', {
        schema: {
            body: {
                type: 'object',
                required: ['url'],
                properties: {
                    url: { type: 'string', format: 'uri' },
                    strategyId: { type: 'string' },
                },
            },
            response: {
                200: {
                    type: 'object',
                    properties: {
                        success: { type: 'boolean' },
                        data: {
                            type: 'object',
                            properties: {
                                primary: {
                                    type: 'object',
                                    properties: {
                                        url: { type: 'string' },
                                        confidence: { type: 'number' },
                                        actions: { type: 'array', items: { type: 'string' } },
                                        redirectionChain: { type: 'array', items: { type: 'string' } },
                                        reason: { type: 'string' },
                                    },
                                },
                                alternatives: {
                                    type: 'array',
                                    items: {
                                        type: 'object',
                                        properties: {
                                            url: { type: 'string' },
                                            confidence: { type: 'number' },
                                            actions: { type: 'array', items: { type: 'string' } },
                                            reason: { type: 'string' },
                                        },
                                    },
                                },
                                meta: {
                                    type: 'object',
                                    properties: {
                                        domain: { type: 'string' },
                                        strategyId: { type: 'string' },
                                        strategyVersion: { type: 'string' },
                                        timing: {
                                            type: 'object',
                                            properties: {
                                                totalMs: { type: 'number' },
                                                redirectMs: { type: 'number' },
                                                processingMs: { type: 'number' },
                                            },
                                        },
                                        appliedAt: { type: 'string' },
                                    },
                                },
                            },
                        },
                        timestamp: { type: 'string' },
                    },
                },
            },
        },
    }, async (request: FastifyRequest<{ Body: CleanRequest }>, reply: FastifyReply) => {
        try {
            const { url, strategyId } = request.body;
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.info({ ...requestInfo, route: 'clean', phase: 'start' }, 'Clean link request received');

            if (!url) {
                const errorPayload = {
                    success: false,
                    error: 'URL is required',
                    timestamp: new Date().toISOString(),
                };
                safeLogger.warn({ ...requestInfo, route: 'clean', phase: 'validation', reason: 'missing_url' }, 'Validation failed: URL missing');
                return reply.status(400).send(errorPayload);
            }

            // Validate URL
            try {
                new URL(url);
            } catch {
                const errorPayload = {
                    success: false,
                    error: 'Invalid URL format',
                    timestamp: new Date().toISOString(),
                };
                safeLogger.warn({ ...requestInfo, route: 'clean', phase: 'validation', reason: 'invalid_url' }, 'Validation failed: Invalid URL');
                return reply.status(400).send(errorPayload);
            }

            const result = await strategyEngine.cleanUrl(url, strategyId);
            safeLogger.info({ ...requestInfo, route: 'clean', phase: 'end' }, 'Clean link request completed');

            const response: ApiResponse<CleanResult> = {
                success: true,
                data: result,
                timestamp: new Date().toISOString(),
            };

            return reply.send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, route: 'clean', phase: 'error', error: error instanceof Error ? error.message : String(error) }, 'Unhandled error during clean');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });

    // POST /api/preview
    fastify.post<{ Body: PreviewRequest }>('/preview', {
        schema: {
            body: {
                type: 'object',
                required: ['url'],
                properties: {
                    url: { type: 'string', format: 'uri' },
                    strategyId: { type: 'string' },
                },
            },
        },
    }, async (request: FastifyRequest<{ Body: PreviewRequest }>, reply: FastifyReply) => {
        try {
            const { url, strategyId } = request.body;
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.info({ ...requestInfo, route: 'preview', phase: 'start' }, 'Preview request received');

            if (!url) {
                const errorPayload = {
                    success: false,
                    error: 'URL is required',
                    timestamp: new Date().toISOString(),
                };
                safeLogger.warn({ ...requestInfo, route: 'preview', phase: 'validation', reason: 'missing_url' }, 'Validation failed: URL missing');
                return reply.status(400).send(errorPayload);
            }

            // Validate URL
            try {
                new URL(url);
            } catch {
                const errorPayload = {
                    success: false,
                    error: 'Invalid URL format',
                    timestamp: new Date().toISOString(),
                };
                safeLogger.warn({ ...requestInfo, route: 'preview', phase: 'validation', reason: 'invalid_url' }, 'Validation failed: Invalid URL');
                return reply.status(400).send(errorPayload);
            }

            // Preview is the same as clean for now, but could be extended
            const result = await strategyEngine.cleanUrl(url, strategyId);
            safeLogger.info({ ...requestInfo, route: 'preview', phase: 'end' }, 'Preview request completed');

            const response: ApiResponse<CleanResult> = {
                success: true,
                data: result,
                timestamp: new Date().toISOString(),
            };

            return reply.send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, route: 'preview', phase: 'error', error: error instanceof Error ? error.message : String(error) }, 'Unhandled error during preview');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });

    // GET /api/health
    fastify.get('/health', async (_request, _reply) => {
        return { status: 'ok', timestamp: new Date().toISOString() };
    });

    // GET /api/rate-limit-status
    fastify.get('/rate-limit-status', async (request: FastifyRequest, reply: FastifyReply) => {
        try {
            const { rateLimiterService } = await import('../middleware/rateLimiter');

            const status = {
                general: await rateLimiterService.getRateLimitStatus(request, 'general'),
                clean: await rateLimiterService.getRateLimitStatus(request, 'clean'),
                health: await rateLimiterService.getRateLimitStatus(request, 'health'),
                admin: await rateLimiterService.getRateLimitStatus(request, 'admin'),
                config: rateLimiterService.getConfig(),
                timestamp: new Date().toISOString(),
            };

            return reply.send({
                success: true,
                data: status,
                timestamp: new Date().toISOString(),
            });
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, error: error instanceof Error ? error.message : String(error) }, 'Failed to get rate limit status');
            return reply.status(500).send({
                success: false,
                error: 'Failed to get rate limit status',
                timestamp: new Date().toISOString(),
            });
        }
    });
}
