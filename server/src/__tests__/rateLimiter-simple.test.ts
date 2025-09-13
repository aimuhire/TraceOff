import { describe, test, expect, beforeEach, afterEach } from '@jest/globals';
import Fastify from 'fastify';
import rateLimit from '@fastify/rate-limit';

describe('Rate Limiter Simple Test', () => {
    let fastify: any;

    beforeEach(async () => {
        fastify = Fastify({
            logger: false,
        });

        // Register a simple rate limiter
        await fastify.register(rateLimit, {
            max: 2, // Only 2 requests
            timeWindow: '1m',
        });

        // Add a test route
        fastify.get('/test', async () => {
            return { success: true };
        });

        await fastify.ready();
    });

    afterEach(async () => {
        await fastify.close();
    });

    test('should allow requests within rate limit', async () => {
        const response1 = await fastify.inject({
            method: 'GET',
            url: '/test',
        });
        expect(response1.statusCode).toBe(200);

        const response2 = await fastify.inject({
            method: 'GET',
            url: '/test',
        });
        expect(response2.statusCode).toBe(200);
    });

    test('should block requests exceeding rate limit', async () => {
        // Make 2 requests (the limit)
        await fastify.inject({ method: 'GET', url: '/test' });
        await fastify.inject({ method: 'GET', url: '/test' });

        // Third request should be rate limited
        const response = await fastify.inject({
            method: 'GET',
            url: '/test',
        });

        expect(response.statusCode).toBe(429);
        const body = JSON.parse(response.payload);
        expect(body.message).toBe('Rate limit exceeded, retry in 1 minute');
    });
});
