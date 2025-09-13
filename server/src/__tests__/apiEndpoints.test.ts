import Fastify from 'fastify';
import { cleanRoutes } from '../routes/clean';
import { strategyRoutes } from '../routes/strategies';

// Mock environment variables
const originalEnv = process.env;
beforeEach(() => {
    process.env = {
        ...originalEnv,
        ADMIN_SECRET: 'a'.repeat(64),
        RATE_LIMIT_CLEAN_MAX: '100',
        RATE_LIMIT_CLEAN_WINDOW: '1m',
        RATE_LIMIT_GENERAL_MAX: '100',
        RATE_LIMIT_GENERAL_WINDOW: '1m',
        RATE_LIMIT_HEALTH_MAX: '1000',
        RATE_LIMIT_HEALTH_WINDOW: '1m',
        RATE_LIMIT_ADMIN_MAX: '50',
        RATE_LIMIT_ADMIN_WINDOW: '1m',
    };
});

afterEach(() => {
    process.env = originalEnv;
});

describe('API Endpoints', () => {
    let app: any;

    beforeEach(async () => {
        app = Fastify({
            logger: false, // Disable logging for tests
        });

        // Register routes
        await app.register(cleanRoutes, { prefix: '/api' });
        await app.register(strategyRoutes, { prefix: '/api' });

        await app.ready();
    });

    afterEach(async () => {
        if (app) {
            await app.close();
        }
    });

    describe('POST /api/clean', () => {
        test('should clean a valid URL', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: {
                    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=test&utm_medium=email'
                }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data).toHaveProperty('primary');
            expect(data.data.primary).toHaveProperty('url');
            expect(data.data.primary).toHaveProperty('confidence');
            expect(data.data.primary).toHaveProperty('actions');
        });

        test('should reject missing URL', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: {}
            });

            expect(response.statusCode).toBe(400);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('URL is required');
        });

        test('should reject invalid URL format', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: {
                    url: 'not-a-valid-url'
                }
            });

            expect(response.statusCode).toBe(400);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid URL format');
        });

        test('should handle empty URL', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: {
                    url: ''
                }
            });

            expect(response.statusCode).toBe(400);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('URL is required');
        });

        test('should accept strategyId parameter', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: {
                    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=test',
                    strategyId: 'youtube'
                }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
        });
    });

    describe('POST /api/preview', () => {
        test('should preview a valid URL', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/preview',
                payload: {
                    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=test&utm_medium=email'
                }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data).toHaveProperty('primary');
        });

        test('should reject missing URL', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/preview',
                payload: {}
            });

            expect(response.statusCode).toBe(400);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('URL is required');
        });

        test('should reject invalid URL format', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/preview',
                payload: {
                    url: 'not-a-valid-url'
                }
            });

            expect(response.statusCode).toBe(400);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid URL format');
        });
    });

    describe('GET /api/health', () => {
        test('should return health status', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.status).toBe('ok');
            expect(data).toHaveProperty('timestamp');
        });
    });

    describe('GET /api/rate-limit-status', () => {
        test('should return rate limit status', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data).toHaveProperty('general');
            expect(data.data).toHaveProperty('clean');
            expect(data.data).toHaveProperty('health');
            expect(data.data).toHaveProperty('admin');
            expect(data.data).toHaveProperty('config');
        });
    });

    describe('GET /api/strategies', () => {
        test('should return strategies list', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/strategies'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data).toBeInstanceOf(Array);
            expect(data.pagination).toHaveProperty('page');
            expect(data.pagination).toHaveProperty('limit');
            expect(data.pagination).toHaveProperty('total');
            expect(data.pagination).toHaveProperty('totalPages');
        });

        test('should support pagination', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/strategies?page=1&limit=5'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.pagination.page).toBe(1);
            expect(data.pagination.limit).toBe(5);
        });

        test('should filter by enabled status', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/strategies?enabled=true'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            data.data.forEach((strategy: any) => {
                expect(strategy.enabled).toBe(true);
            });
        });
    });

    describe('GET /api/strategies/:id', () => {
        test('should return specific strategy', async () => {
            // First get the list to find a valid ID
            const listResponse = await app.inject({
                method: 'GET',
                url: '/api/strategies'
            });
            const listData = JSON.parse(listResponse.payload);
            const strategyId = listData.data[0]?.id;

            if (strategyId) {
                const response = await app.inject({
                    method: 'GET',
                    url: `/api/strategies/${strategyId}`
                });

                expect(response.statusCode).toBe(200);
                const data = JSON.parse(response.payload);
                expect(data.success).toBe(true);
                expect(data.data.id).toBe(strategyId);
            }
        });

        test('should return 404 for non-existent strategy', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/strategies/non-existent-id'
            });

            expect(response.statusCode).toBe(404);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Strategy not found');
        });
    });

    describe('Error handling', () => {
        test('should handle malformed JSON', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: 'invalid json'
            });

            expect(response.statusCode).toBe(400);
        });

        test('should handle missing content-type', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: JSON.stringify({
                    url: 'https://example.com'
                }),
                headers: {
                    'content-type': 'text/plain'
                }
            });

            expect(response.statusCode).toBe(400);
        });
    });
});
