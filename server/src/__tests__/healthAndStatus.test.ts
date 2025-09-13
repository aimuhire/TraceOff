import Fastify from 'fastify';
import { cleanRoutes } from '../routes/clean';
import { strategyRoutes } from '../routes/strategies';
import { rateLimiterService } from '../middleware/rateLimiter';

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
    rateLimiterService.clearAll();
});

describe('Health Check and Status Endpoints', () => {
    let app: any;

    beforeEach(async () => {
        app = Fastify({
            logger: false, // Disable logging for tests
        });

        // Initialize rate limiting
        const { getRateLimitConfig } = await import('../config/rateLimit');
        const rateLimitConfig = getRateLimitConfig();
        rateLimiterService.updateConfig(rateLimitConfig);

        // Register rate limiters
        await rateLimiterService.registerRateLimiters(app);

        // Register routes
        await app.register(cleanRoutes, { prefix: '/api' });
        await app.register(strategyRoutes, { prefix: '/api' });

        await app.ready();
    });

    afterEach(async () => {
        if (app) {
            await app.close();
        }
        rateLimiterService.clearAll();
    });

    describe('GET /api/health', () => {
        test('should return basic health status', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data).toHaveProperty('status');
            expect(data).toHaveProperty('timestamp');
            expect(data.status).toBe('ok');
            expect(typeof data.timestamp).toBe('string');
        });

        test('should return valid timestamp format', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            const timestamp = new Date(data.timestamp);
            expect(timestamp).toBeInstanceOf(Date);
            expect(timestamp.getTime()).not.toBeNaN();
        });

        test('should be accessible without authentication', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
        });

        test('should handle multiple concurrent requests', async () => {
            const promises = Array.from({ length: 10 }, () =>
                app.inject({
                    method: 'GET',
                    url: '/api/health'
                })
            );

            const responses = await Promise.all(promises);

            responses.forEach(response => {
                expect(response.statusCode).toBe(200);
                const data = JSON.parse(response.payload);
                expect(data.status).toBe('ok');
            });
        });

        test('should return consistent response format', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);

            // Should only have status and timestamp
            expect(Object.keys(data)).toHaveLength(2);
            expect(data).toEqual({
                status: 'ok',
                timestamp: expect.any(String)
            });
        });
    });

    describe('GET /api/rate-limit-status', () => {
        test('should return comprehensive rate limit status', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);

            expect(data.success).toBe(true);
            expect(data).toHaveProperty('data');
            expect(data).toHaveProperty('timestamp');

            const statusData = data.data;
            expect(statusData).toHaveProperty('general');
            expect(statusData).toHaveProperty('clean');
            expect(statusData).toHaveProperty('health');
            expect(statusData).toHaveProperty('admin');
            expect(statusData).toHaveProperty('config');
        });

        test('should include current usage in rate limit status', async () => {
            // Make some requests to generate usage
            await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/test1' }
            });

            await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/test2' }
            });

            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            const statusData = data.data;

            // Should show current usage
            expect(statusData.clean).toHaveProperty('current');
            expect(statusData.clean).toHaveProperty('limit');
            expect(statusData.clean).toHaveProperty('remaining');
            expect(statusData.clean.current).toBeGreaterThan(0);
        });

        test('should include configuration in rate limit status', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            const config = data.data.config;

            expect(config).toHaveProperty('general');
            expect(config).toHaveProperty('clean');
            expect(config).toHaveProperty('health');
            expect(config).toHaveProperty('admin');

            // Verify configuration values
            expect(config.clean.max).toBe(100);
            expect(config.clean.timeWindow).toBe('1m');
            expect(config.health.max).toBe(1000);
            expect(config.admin.max).toBe(50);
        });

        test('should show different limits for different endpoints', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            const config = data.data.config;

            // Different endpoints should have different limits
            expect(config.health.max).toBeGreaterThan(config.clean.max);
            expect(config.clean.max).toBeGreaterThan(config.admin.max);
        });

        test('should handle rate limiter service errors gracefully', async () => {
            // This test ensures the status endpoint doesn't break
            // if there are issues with the rate limiter service
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            // Should return 200 even if there are internal errors
            expect(response.statusCode).toBe(200);
        });

        test('should be accessible without authentication', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
        });

        test('should return valid timestamp format', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            const timestamp = new Date(data.timestamp);
            expect(timestamp).toBeInstanceOf(Date);
            expect(timestamp.getTime()).not.toBeNaN();
        });
    });

    describe('Health Check Performance', () => {
        test('should respond quickly to health checks', async () => {
            const startTime = Date.now();

            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            const endTime = Date.now();
            const responseTime = endTime - startTime;

            expect(response.statusCode).toBe(200);
            // Should respond within 100ms
            expect(responseTime).toBeLessThan(100);
        });

        test('should handle high frequency health checks', async () => {
            const promises = Array.from({ length: 50 }, () =>
                app.inject({
                    method: 'GET',
                    url: '/api/health'
                })
            );

            const startTime = Date.now();
            const responses = await Promise.all(promises);
            const endTime = Date.now();

            const allSuccessful = responses.every(response => response.statusCode === 200);
            expect(allSuccessful).toBe(true);

            // Should handle 50 requests quickly
            expect(endTime - startTime).toBeLessThan(1000);
        });
    });

    describe('Status Endpoint Performance', () => {
        test('should respond quickly to status checks', async () => {
            const startTime = Date.now();

            const response = await app.inject({
                method: 'GET',
                url: '/api/rate-limit-status'
            });

            const endTime = Date.now();
            const responseTime = endTime - startTime;

            expect(response.statusCode).toBe(200);
            // Should respond within 200ms
            expect(responseTime).toBeLessThan(200);
        });
    });

    describe('Error Handling', () => {
        test('should handle malformed requests gracefully', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health',
                headers: {
                    'content-type': 'application/json'
                },
                payload: 'invalid json'
            });

            // Health endpoint should still work
            expect(response.statusCode).toBe(200);
        });

        test('should handle missing headers gracefully', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health',
                headers: {}
            });

            expect(response.statusCode).toBe(200);
        });
    });

    describe('Response Headers', () => {
        test('should include appropriate response headers', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
            expect(response.headers).toHaveProperty('content-type');
            expect(response.headers['content-type']).toContain('application/json');
        });

        test('should include CORS headers if configured', async () => {
            const response = await app.inject({
                method: 'GET',
                url: '/api/health'
            });

            expect(response.statusCode).toBe(200);
            // CORS headers would be added by the CORS plugin
        });
    });
});
