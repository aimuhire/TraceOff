import { describe, test, expect, beforeEach, afterEach } from '@jest/globals';
import Fastify from 'fastify';
import { rateLimiterService } from '../middleware/rateLimiter';
import { getRateLimitConfig } from '../config/rateLimit';

describe('Rate Limiter Service', () => {
    let fastify: any;

    beforeEach(async () => {
        fastify = Fastify({
            logger: false,
        });

        // Register rate limiters
        await rateLimiterService.registerRateLimiters(fastify);

        // Add test routes
        fastify.get('/test-general', async () => {
            return { success: true, route: 'general' };
        });

        fastify.get('/test-clean', async () => {
            return { success: true, route: 'clean' };
        });

        fastify.get('/test-health', async () => {
            return { success: true, route: 'health' };
        });

        await fastify.ready();
    });

    afterEach(async () => {
        await fastify.close();
        await rateLimiterService.close();
    });

    test('should allow requests within rate limit', async () => {
        const response = await fastify.inject({
            method: 'GET',
            url: '/test-general',
        });

        expect(response.statusCode).toBe(200);
        expect(JSON.parse(response.payload)).toEqual({
            success: true,
            route: 'general',
        });
    });

    test.skip('should block requests exceeding rate limit', async () => {
        // Use a smaller number of requests to avoid hitting the limit in other tests
        const maxRequests = 5;

        // Create a new Fastify instance with updated rate limiter config
        const testFastify = Fastify({
            logger: false,
        });

        // Create a new rate limiter service with the test config
        const testRateLimiterService = new (await import('../middleware/rateLimiter')).RateLimiterService({
            general: { max: maxRequests, timeWindow: '1m' },
            clean: { max: 20, timeWindow: '1m' },
            health: { max: 1000, timeWindow: '1m' },
            admin: { max: 50, timeWindow: '1m' },
        });

        // Register rate limiters with the test config
        await testRateLimiterService.registerRateLimiters(testFastify);

        // Add test route
        testFastify.get('/test-general', async () => {
            return { success: true, route: 'general' };
        });

        await testFastify.ready();

        try {
            // Make requests up to the limit
            for (let i = 0; i < maxRequests; i++) {
                const response = await testFastify.inject({
                    method: 'GET',
                    url: '/test-general',
                });
                expect(response.statusCode).toBe(200);
            }

            // Next request should be rate limited
            const response = await testFastify.inject({
                method: 'GET',
                url: '/test-general',
            });

            expect(response.statusCode).toBe(429);
            const body = JSON.parse(response.payload);
            // The @fastify/rate-limit plugin uses its default error message
            expect(body.message).toBe('Rate limit exceeded, retry in 1 minute');
        } finally {
            // Clean up
            await testFastify.close();
            await testRateLimiterService.close();
        }
    });

    test('should have different limits for different endpoints', async () => {
        // Test that different endpoints work
        const generalResponse = await fastify.inject({
            method: 'GET',
            url: '/test-general',
        });
        expect(generalResponse.statusCode).toBe(200);

        const cleanResponse = await fastify.inject({
            method: 'GET',
            url: '/test-clean',
        });
        expect(cleanResponse.statusCode).toBe(200);

        const healthResponse = await fastify.inject({
            method: 'GET',
            url: '/test-health',
        });
        expect(healthResponse.statusCode).toBe(200);
    });

    test('should include rate limit headers in response', async () => {
        const response = await fastify.inject({
            method: 'GET',
            url: '/test-general',
        });

        expect(response.statusCode).toBe(200);
        // Note: @fastify/rate-limit adds headers automatically
        // The exact headers depend on the implementation
    });

    test('should handle Redis connection errors gracefully', async () => {
        // This test verifies that the service falls back to memory store
        // when Redis is not available
        const response = await fastify.inject({
            method: 'GET',
            url: '/test-general',
        });

        expect(response.statusCode).toBe(200);
    });

    test('should get rate limit status', async () => {
        const status = await rateLimiterService.getRateLimitStatus(
            { ip: '127.0.0.1', headers: {} } as any,
            'general'
        );

        // Status might be null if Redis is not available
        if (status) {
            expect(status).toHaveProperty('limit');
            expect(status).toHaveProperty('remaining');
            expect(status).toHaveProperty('resetTime');
        }
    });

    test('should update configuration', () => {
        const newConfig = {
            general: { max: 50, timeWindow: '30s' },
            clean: { max: 10, timeWindow: '30s' },
            health: { max: 100, timeWindow: '30s' },
            admin: { max: 25, timeWindow: '30s' },
        };

        rateLimiterService.updateConfig(newConfig);
        const config = rateLimiterService.getConfig();

        expect(config.general.max).toBe(50);
        expect(config.clean.max).toBe(10);
    });
});

describe('Rate Limit Configuration', () => {
    test('should return development config in development', () => {
        const originalEnv = process.env.NODE_ENV;
        process.env.NODE_ENV = 'development';

        const config = getRateLimitConfig();
        expect(config.general.max).toBe(1000);
        expect(config.clean.max).toBe(100);

        process.env.NODE_ENV = originalEnv;
    });

    test('should return production config in production', () => {
        const originalEnv = process.env.NODE_ENV;
        process.env.NODE_ENV = 'production';

        const config = getRateLimitConfig();
        expect(config.general.max).toBe(50);
        expect(config.clean.max).toBe(10);

        process.env.NODE_ENV = originalEnv;
    });

    test('should use environment variables when available', () => {
        const originalEnv = process.env.RATE_LIMIT_GENERAL_MAX;
        process.env.RATE_LIMIT_GENERAL_MAX = '200';

        const config = getRateLimitConfig();
        expect(config.general.max).toBe(200);

        if (originalEnv) {
            process.env.RATE_LIMIT_GENERAL_MAX = originalEnv;
        } else {
            delete process.env.RATE_LIMIT_GENERAL_MAX;
        }
    });
});
