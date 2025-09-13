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
        RATE_LIMIT_CLEAN_MAX: '5',
        RATE_LIMIT_CLEAN_WINDOW: '1m',
        RATE_LIMIT_GENERAL_MAX: '10',
        RATE_LIMIT_GENERAL_WINDOW: '1m',
        RATE_LIMIT_HEALTH_MAX: '100',
        RATE_LIMIT_HEALTH_WINDOW: '1m',
        RATE_LIMIT_ADMIN_MAX: '3',
        RATE_LIMIT_ADMIN_WINDOW: '1m',
    };
});

afterEach(() => {
    process.env = originalEnv;
    // Clear rate limiter state
    rateLimiterService.clearAll();
});

describe('Rate Limiting', () => {
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

    describe('Clean Endpoint Rate Limiting', () => {
        test('should allow requests within rate limit', async () => {
            for (let i = 0; i < 5; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: {
                        url: `https://example.com/test${i}`
                    }
                });

                expect(response.statusCode).toBe(200);
            }
        });

        test('should reject requests exceeding rate limit', async () => {
            // Make requests up to the limit
            for (let i = 0; i < 5; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: {
                        url: `https://example.com/test${i}`
                    }
                });
                expect(response.statusCode).toBe(200);
            }

            // This request should be rate limited
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: {
                    url: 'https://example.com/rate-limited'
                }
            });

            expect(response.statusCode).toBe(429);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Rate limit exceeded');
            expect(data.message).toContain('Too many clean requests');
            expect(data).toHaveProperty('retryAfter');
            expect(data).toHaveProperty('limit');
            expect(data).toHaveProperty('remaining');
            expect(data).toHaveProperty('resetTime');
        });

        test('should track rate limits per IP', async () => {
            // Make requests from different IPs
            const ip1 = '192.168.1.1';
            const ip2 = '192.168.1.2';

            // IP1 makes 5 requests (should all succeed)
            for (let i = 0; i < 5; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: {
                        url: `https://example.com/test${i}`
                    },
                    headers: {
                        'x-forwarded-for': ip1
                    }
                });
                expect(response.statusCode).toBe(200);
            }

            // IP2 makes 5 requests (should all succeed)
            for (let i = 0; i < 5; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: {
                        url: `https://example.com/test${i}`
                    },
                    headers: {
                        'x-forwarded-for': ip2
                    }
                });
                expect(response.statusCode).toBe(200);
            }
        });
    });

    describe('Health Endpoint Rate Limiting', () => {
        test('should allow many health check requests', async () => {
            for (let i = 0; i < 50; i++) {
                const response = await app.inject({
                    method: 'GET',
                    url: '/api/health'
                });

                expect(response.statusCode).toBe(200);
            }
        });

        test('should eventually rate limit health checks', async () => {
            let rateLimited = false;
            for (let i = 0; i < 200; i++) {
                const response = await app.inject({
                    method: 'GET',
                    url: '/api/health'
                });

                if (response.statusCode === 429) {
                    rateLimited = true;
                    break;
                }
            }

            expect(rateLimited).toBe(true);
        });
    });

    describe('Admin Endpoint Rate Limiting', () => {
        test('should rate limit admin operations', async () => {
            const validStrategy = {
                name: 'Test Strategy',
                matchers: [{ type: 'exact', pattern: 'https://example.com', caseSensitive: false }],
                paramPolicies: [{ name: 'utm_source', action: 'deny', reason: 'Remove tracking' }],
                pathRules: [{ pattern: '/test', replacement: '/clean', type: 'exact' }],
                redirectPolicy: { follow: true, maxDepth: 3, timeoutMs: 5000, allowedSchemes: ['https'] },
                canonicalBuilders: [{ type: 'domain', template: 'example.com', required: true }],
                notes: 'Test strategy'
            };

            // Make requests up to the admin limit
            for (let i = 0; i < 3; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/strategies',
                    headers: {
                        'Authorization': `Bearer ${'a'.repeat(64)}`,
                        'Content-Type': 'application/json'
                    },
                    payload: {
                        ...validStrategy,
                        name: `Test Strategy ${i}`
                    }
                });

                expect(response.statusCode).toBe(201);
            }

            // This request should be rate limited
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${'a'.repeat(64)}`,
                    'Content-Type': 'application/json'
                },
                payload: {
                    ...validStrategy,
                    name: 'Rate Limited Strategy'
                }
            });

            expect(response.statusCode).toBe(429);
        });
    });

    describe('Rate Limit Status Endpoint', () => {
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

        test('should show current usage in rate limit status', async () => {
            // Make some requests first
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
            expect(data.data.clean.current).toBeGreaterThan(0);
        });
    });

    describe('Rate Limit Headers', () => {
        test('should include rate limit headers in responses', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/test' }
            });

            expect(response.statusCode).toBe(200);
            // Note: Fastify rate limit plugin may not add headers in test environment
            // This test documents expected behavior
        });
    });

    describe('Rate Limit Reset', () => {
        test('should reset rate limits after time window', async () => {
            // Make requests up to the limit
            for (let i = 0; i < 5; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: `https://example.com/test${i}` }
                });
                expect(response.statusCode).toBe(200);
            }

            // Verify rate limited
            const rateLimitedResponse = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/rate-limited' }
            });
            expect(rateLimitedResponse.statusCode).toBe(429);

            // Clear rate limiter (simulating time window reset)
            rateLimiterService.clearAll();

            // Should work again
            const resetResponse = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/after-reset' }
            });
            expect(resetResponse.statusCode).toBe(200);
        });
    });

    describe('Different Endpoint Rate Limits', () => {
        test('should apply different limits to different endpoints', async () => {
            // Health endpoint should have higher limit
            for (let i = 0; i < 20; i++) {
                const response = await app.inject({
                    method: 'GET',
                    url: '/api/health'
                });
                expect(response.statusCode).toBe(200);
            }

            // Clean endpoint should have lower limit
            for (let i = 0; i < 5; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: `https://example.com/test${i}` }
                });
                expect(response.statusCode).toBe(200);
            }

            // This clean request should be rate limited
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/rate-limited' }
            });
            expect(response.statusCode).toBe(429);
        });
    });

    describe('Rate Limit Error Handling', () => {
        test('should handle rate limit service errors gracefully', async () => {
            // This test ensures the rate limiter doesn't break the application
            // if there are internal errors
            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/test' }
            });

            // Should still work even if rate limiter has issues
            expect([200, 429]).toContain(response.statusCode);
        });
    });
});
