import { FastifyInstance } from 'fastify';
import { Strategy, StrategyRequest, StrategyUpdateRequest, ApiResponse } from '../types';
import { StrategyEngine } from '../engine/StrategyEngine';
import { nanoid } from 'nanoid';
import { createSafeLogger, getSafeRequestInfo } from '../utils/logger';
import { createAdminAuthMiddleware } from '../middleware/adminAuth';

export async function strategyRoutes(fastify: FastifyInstance) {
    const strategyEngine = new StrategyEngine();
    const safeLogger = createSafeLogger(fastify.log);

    // Initialize admin authentication middleware
    const adminSecret = process.env.ADMIN_SECRET;
    if (!adminSecret || adminSecret.length !== 64) {
        safeLogger.error({
            hasSecret: !!adminSecret,
            secretLength: adminSecret?.length || 0
        }, 'Admin secret not properly configured for strategy routes');
        throw new Error('ADMIN_SECRET must be a 64-character string');
    }
    const adminAuth = createAdminAuthMiddleware({ adminSecret });

    // Initialize with default strategies
    const { StrategyFactory } = await import('../engine/strategies');
    const strategies = StrategyFactory.createAllStrategies();
    strategies.forEach(strategy => strategyEngine.addStrategy(strategy));

    // GET /api/strategies
    fastify.get('/strategies', {
        preHandler: adminAuth,
        schema: {
            querystring: {
                type: 'object',
                properties: {
                    page: { type: 'number', default: 1 },
                    limit: { type: 'number', default: 50 },
                    enabled: { type: 'boolean' },
                },
            },
        },
    }, async (request, reply) => {
        try {
            const { page = 1, limit = 50, enabled } = request.query as { page?: number; limit?: number; enabled?: boolean };
            let allStrategies = strategyEngine.getAllStrategies();

            // Filter by enabled status if specified
            if (enabled !== undefined) {
                allStrategies = allStrategies.filter(s => s.enabled === enabled);
            }

            // Pagination
            const startIndex = (page - 1) * limit;
            const endIndex = startIndex + limit;
            const paginatedStrategies = allStrategies.slice(startIndex, endIndex);

            const response: ApiResponse<{ strategies: Strategy[]; pagination: { page: number; limit: number; total: number; totalPages: number } }> = {
                success: true,
                data: {
                    strategies: paginatedStrategies,
                    pagination: {
                        page,
                        limit,
                        total: allStrategies.length,
                        totalPages: Math.ceil(allStrategies.length / limit),
                    }
                },
                timestamp: new Date().toISOString(),
            };

            return reply.send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, error: error instanceof Error ? error.message : String(error) }, 'Strategy operation error');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });

    // GET /api/strategies/:id
    fastify.get<{ Params: { id: string } }>('/strategies/:id', {
        preHandler: adminAuth,
        schema: {
            params: {
                type: 'object',
                required: ['id'],
                properties: {
                    id: { type: 'string' },
                },
            },
        },
    }, async (request, reply) => {
        try {
            const { id } = request.params as { id: string };
            const strategy = strategyEngine.getStrategy(id);

            if (!strategy) {
                return reply.status(404).send({
                    success: false,
                    error: 'Strategy not found',
                    timestamp: new Date().toISOString(),
                });
            }

            const response: ApiResponse<Strategy> = {
                success: true,
                data: strategy,
                timestamp: new Date().toISOString(),
            };

            return reply.send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, error: error instanceof Error ? error.message : String(error) }, 'Strategy operation error');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });

    // POST /api/strategies
    fastify.post<{ Body: StrategyRequest }>('/strategies', {
        preHandler: adminAuth,
        schema: {
            body: {
                type: 'object',
                required: ['name', 'matchers', 'paramPolicies', 'pathRules', 'redirectPolicy', 'canonicalBuilders'],
                properties: {
                    name: { type: 'string' },
                    matchers: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                type: { type: 'string', enum: ['exact', 'wildcard', 'regex'] },
                                pattern: { type: 'string' },
                                caseSensitive: { type: 'boolean' },
                            },
                        },
                    },
                    paramPolicies: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                name: { type: 'string' },
                                action: { type: 'string', enum: ['allow', 'deny', 'conditional'] },
                                condition: { type: 'string' },
                                reason: { type: 'string' },
                            },
                        },
                    },
                    pathRules: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                pattern: { type: 'string' },
                                replacement: { type: 'string' },
                                type: { type: 'string', enum: ['regex', 'exact'] },
                            },
                        },
                    },
                    redirectPolicy: {
                        type: 'object',
                        properties: {
                            follow: { type: 'boolean' },
                            maxDepth: { type: 'number' },
                            timeoutMs: { type: 'number' },
                            allowedSchemes: { type: 'array', items: { type: 'string' } },
                        },
                    },
                    canonicalBuilders: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                type: { type: 'string', enum: ['domain', 'path', 'query'] },
                                template: { type: 'string' },
                                required: { type: 'boolean' },
                            },
                        },
                    },
                    notes: { type: 'string' },
                },
            },
        },
    }, async (request, reply) => {
        try {
            const strategyData = request.body as StrategyRequest;
            const id = nanoid();
            const now = new Date().toISOString();

            const strategy: Strategy = {
                id,
                name: strategyData.name,
                version: '1.0.0',
                enabled: true,
                priority: 50,
                matchers: strategyData.matchers,
                paramPolicies: strategyData.paramPolicies,
                pathRules: strategyData.pathRules,
                redirectPolicy: strategyData.redirectPolicy,
                canonicalBuilders: strategyData.canonicalBuilders,
                notes: strategyData.notes,
                createdAt: now,
                updatedAt: now,
            };

            strategyEngine.addStrategy(strategy);

            const response: ApiResponse<Strategy> = {
                success: true,
                data: strategy,
                timestamp: new Date().toISOString(),
            };

            return reply.status(201).send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, error: error instanceof Error ? error.message : String(error) }, 'Strategy operation error');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });

    // PUT /api/strategies/:id
    fastify.put<{ Params: { id: string }; Body: StrategyUpdateRequest }>('/strategies/:id', {
        preHandler: adminAuth,
        schema: {
            params: {
                type: 'object',
                required: ['id'],
                properties: {
                    id: { type: 'string' },
                },
            },
            body: {
                type: 'object',
                properties: {
                    name: { type: 'string' },
                    enabled: { type: 'boolean' },
                    priority: { type: 'number' },
                    matchers: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                type: { type: 'string', enum: ['exact', 'wildcard', 'regex'] },
                                pattern: { type: 'string' },
                                caseSensitive: { type: 'boolean' },
                            },
                        },
                    },
                    paramPolicies: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                name: { type: 'string' },
                                action: { type: 'string', enum: ['allow', 'deny', 'conditional'] },
                                condition: { type: 'string' },
                                reason: { type: 'string' },
                            },
                        },
                    },
                    pathRules: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                pattern: { type: 'string' },
                                replacement: { type: 'string' },
                                type: { type: 'string', enum: ['regex', 'exact'] },
                            },
                        },
                    },
                    redirectPolicy: {
                        type: 'object',
                        properties: {
                            follow: { type: 'boolean' },
                            maxDepth: { type: 'number' },
                            timeoutMs: { type: 'number' },
                            allowedSchemes: { type: 'array', items: { type: 'string' } },
                        },
                    },
                    canonicalBuilders: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                type: { type: 'string', enum: ['domain', 'path', 'query'] },
                                template: { type: 'string' },
                                required: { type: 'boolean' },
                            },
                        },
                    },
                    notes: { type: 'string' },
                },
            },
        },
    }, async (request, reply) => {
        try {
            const { id } = request.params as { id: string };
            const updateData = request.body as StrategyUpdateRequest;
            const existingStrategy = strategyEngine.getStrategy(id);

            if (!existingStrategy) {
                return reply.status(404).send({
                    success: false,
                    error: 'Strategy not found',
                    timestamp: new Date().toISOString(),
                });
            }

            const updatedStrategy: Strategy = {
                ...existingStrategy,
                ...updateData,
                enabled: updateData.enabled ?? existingStrategy.enabled,
                priority: updateData.priority ?? existingStrategy.priority,
                updatedAt: new Date().toISOString(),
            };

            strategyEngine.addStrategy(updatedStrategy);

            const response: ApiResponse<Strategy> = {
                success: true,
                data: updatedStrategy,
                timestamp: new Date().toISOString(),
            };

            return reply.send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, error: error instanceof Error ? error.message : String(error) }, 'Strategy operation error');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });

    // DELETE /api/strategies/:id
    fastify.delete<{ Params: { id: string } }>('/strategies/:id', {
        preHandler: adminAuth,
        schema: {
            params: {
                type: 'object',
                required: ['id'],
                properties: {
                    id: { type: 'string' },
                },
            },
        },
    }, async (request, reply) => {
        try {
            const { id } = request.params as { id: string };
            const strategy = strategyEngine.getStrategy(id);

            if (!strategy) {
                return reply.status(404).send({
                    success: false,
                    error: 'Strategy not found',
                    timestamp: new Date().toISOString(),
                });
            }

            strategyEngine.removeStrategy(id);

            const response: ApiResponse = {
                success: true,
                timestamp: new Date().toISOString(),
            };

            return reply.send(response);
        } catch (error) {
            const requestInfo = getSafeRequestInfo(request);
            safeLogger.error({ ...requestInfo, error: error instanceof Error ? error.message : String(error) }, 'Strategy operation error');
            return reply.status(500).send({
                success: false,
                error: 'Internal server error',
                timestamp: new Date().toISOString(),
            });
        }
    });
}
