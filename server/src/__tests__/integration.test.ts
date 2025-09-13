import Fastify from 'fastify';
import { cleanRoutes } from '../routes/clean';
import { strategyRoutes } from '../routes/strategies';
import { rateLimiterService } from '../middleware/rateLimiter';

// Mock environment variables
const originalEnv = process.env;
const validAdminSecret = 'a'.repeat(64);

beforeEach(() => {
    process.env = {
        ...originalEnv,
        ADMIN_SECRET: validAdminSecret,
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

describe('Integration Tests - Complete Application Flow', () => {
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

    describe('Complete URL Cleaning Workflow', () => {
        test('should clean YouTube URLs with tracking parameters', async () => {
            const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=test&utm_medium=email&utm_campaign=newsletter&fbclid=123456';

            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: testUrl }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);

            expect(data.success).toBe(true);
            expect(data.data.primary.url).not.toContain('utm_source');
            expect(data.data.primary.url).not.toContain('utm_medium');
            expect(data.data.primary.url).not.toContain('utm_campaign');
            expect(data.data.primary.url).not.toContain('fbclid');
            expect(data.data.primary.url).toContain('v=dQw4w9WgXcQ');
            expect(data.data.primary.confidence).toBeGreaterThan(0);
            expect(data.data.primary.actions).toContain('removed_tracking_params');
        });

        test('should clean Instagram URLs with tracking parameters', async () => {
            const testUrl = 'https://www.instagram.com/p/ABC123/?utm_source=ig_web&utm_medium=share&igshid=xyz789';

            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: testUrl }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);

            expect(data.success).toBe(true);
            expect(data.data.primary.url).not.toContain('utm_source');
            expect(data.data.primary.url).not.toContain('utm_medium');
            expect(data.data.primary.url).not.toContain('igshid');
            expect(data.data.primary.url).toContain('/p/ABC123/');
        });

        test('should handle Twitter/X URLs', async () => {
            const testUrl = 'https://twitter.com/user/status/1234567890?ref_src=twsrc%5Etfw&utm_source=twitter&utm_medium=social';

            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: testUrl }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);

            expect(data.success).toBe(true);
            expect(data.data.primary.url).not.toContain('ref_src');
            expect(data.data.primary.url).not.toContain('utm_source');
            expect(data.data.primary.url).not.toContain('utm_medium');
        });

        test('should provide alternative cleaning approaches', async () => {
            const testUrl = 'https://example.com/page?utm_source=test&utm_medium=email&ref=social';

            const response = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: testUrl }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);

            expect(data.success).toBe(true);
            expect(data.data.alternatives).toBeInstanceOf(Array);
            expect(data.data.alternatives.length).toBeGreaterThan(0);

            // Each alternative should have different cleaning approach
            data.data.alternatives.forEach((alt: any) => {
                expect(alt).toHaveProperty('url');
                expect(alt).toHaveProperty('confidence');
                expect(alt).toHaveProperty('actions');
                expect(alt).toHaveProperty('reason');
            });
        });

        test('should handle preview requests the same as clean requests', async () => {
            const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=test';

            const cleanResponse = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: testUrl }
            });

            const previewResponse = await app.inject({
                method: 'POST',
                url: '/api/preview',
                payload: { url: testUrl }
            });

            expect(cleanResponse.statusCode).toBe(200);
            expect(previewResponse.statusCode).toBe(200);

            const cleanData = JSON.parse(cleanResponse.payload);
            const previewData = JSON.parse(previewResponse.payload);

            expect(cleanData.success).toBe(true);
            expect(previewData.success).toBe(true);
            expect(cleanData.data.primary.url).toBe(previewData.data.primary.url);
        });
    });

    describe('Strategy Management Workflow', () => {
        test('should create, read, update, and delete strategies', async () => {
            const strategyData = {
                name: 'Integration Test Strategy',
                matchers: [
                    {
                        type: 'exact',
                        pattern: 'https://test.example.com',
                        caseSensitive: false
                    }
                ],
                paramPolicies: [
                    {
                        name: 'test_param',
                        action: 'deny',
                        reason: 'Remove test parameter'
                    }
                ],
                pathRules: [
                    {
                        pattern: '/test',
                        replacement: '/clean',
                        type: 'exact'
                    }
                ],
                redirectPolicy: {
                    follow: true,
                    maxDepth: 3,
                    timeoutMs: 5000,
                    allowedSchemes: ['https', 'http']
                },
                canonicalBuilders: [
                    {
                        type: 'domain',
                        template: 'test.example.com',
                        required: true
                    }
                ],
                notes: 'Strategy for integration testing'
            };

            // Create strategy
            const createResponse = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: strategyData
            });

            expect(createResponse.statusCode).toBe(201);
            const createdData = JSON.parse(createResponse.payload);
            const strategyId = createdData.data.id;

            // Read strategy
            const readResponse = await app.inject({
                method: 'GET',
                url: `/api/strategies/${strategyId}`
            });

            expect(readResponse.statusCode).toBe(200);
            const readData = JSON.parse(readResponse.payload);
            expect(readData.data.name).toBe('Integration Test Strategy');

            // Update strategy
            const updateResponse = await app.inject({
                method: 'PUT',
                url: `/api/strategies/${strategyId}`,
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: {
                    name: 'Updated Integration Test Strategy',
                    enabled: false,
                    priority: 75
                }
            });

            expect(updateResponse.statusCode).toBe(200);
            const updatedData = JSON.parse(updateResponse.payload);
            expect(updatedData.data.name).toBe('Updated Integration Test Strategy');
            expect(updatedData.data.enabled).toBe(false);
            expect(updatedData.data.priority).toBe(75);

            // Delete strategy
            const deleteResponse = await app.inject({
                method: 'DELETE',
                url: `/api/strategies/${strategyId}`,
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`
                }
            });

            expect(deleteResponse.statusCode).toBe(200);

            // Verify deletion
            const verifyResponse = await app.inject({
                method: 'GET',
                url: `/api/strategies/${strategyId}`
            });

            expect(verifyResponse.statusCode).toBe(404);
        });

        test('should list strategies with pagination', async () => {
            // Get initial list
            const listResponse = await app.inject({
                method: 'GET',
                url: '/api/strategies?page=1&limit=5'
            });

            expect(listResponse.statusCode).toBe(200);
            const listData = JSON.parse(listResponse.payload);
            expect(listData.success).toBe(true);
            expect(listData.data).toBeInstanceOf(Array);
            expect(listData.pagination.page).toBe(1);
            expect(listData.pagination.limit).toBe(5);
            expect(listData.pagination.total).toBeGreaterThan(0);
        });

        test('should filter strategies by enabled status', async () => {
            const enabledResponse = await app.inject({
                method: 'GET',
                url: '/api/strategies?enabled=true'
            });

            expect(enabledResponse.statusCode).toBe(200);
            const enabledData = JSON.parse(enabledResponse.payload);
            enabledData.data.forEach((strategy: any) => {
                expect(strategy.enabled).toBe(true);
            });

            const disabledResponse = await app.inject({
                method: 'GET',
                url: '/api/strategies?enabled=false'
            });

            expect(disabledResponse.statusCode).toBe(200);
            const disabledData = JSON.parse(disabledResponse.payload);
            disabledData.data.forEach((strategy: any) => {
                expect(strategy.enabled).toBe(false);
            });
        });
    });

    describe('Authentication and Authorization Flow', () => {
        test('should protect admin endpoints with authentication', async () => {
            const strategyData = {
                name: 'Auth Test Strategy',
                matchers: [{ type: 'exact', pattern: 'https://test.com', caseSensitive: false }],
                paramPolicies: [{ name: 'test', action: 'deny', reason: 'test' }],
                pathRules: [{ pattern: '/test', replacement: '/clean', type: 'exact' }],
                redirectPolicy: { follow: true, maxDepth: 3, timeoutMs: 5000, allowedSchemes: ['https'] },
                canonicalBuilders: [{ type: 'domain', template: 'test.com', required: true }],
                notes: 'test'
            };

            // Should fail without auth
            const noAuthResponse = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                payload: strategyData
            });
            expect(noAuthResponse.statusCode).toBe(401);

            // Should fail with wrong auth
            const wrongAuthResponse = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: { 'Authorization': 'Bearer wrong-token' },
                payload: strategyData
            });
            expect(wrongAuthResponse.statusCode).toBe(401);

            // Should succeed with correct auth
            const correctAuthResponse = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: { 'Authorization': `Bearer ${validAdminSecret}` },
                payload: strategyData
            });
            expect(correctAuthResponse.statusCode).toBe(201);
        });

        test('should allow public access to read-only endpoints', async () => {
            // These should work without authentication
            const healthResponse = await app.inject({
                method: 'GET',
                url: '/api/health'
            });
            expect(healthResponse.statusCode).toBe(200);

            const strategiesResponse = await app.inject({
                method: 'GET',
                url: '/api/strategies'
            });
            expect(strategiesResponse.statusCode).toBe(200);

            const cleanResponse = await app.inject({
                method: 'POST',
                url: '/api/clean',
                payload: { url: 'https://example.com/test' }
            });
            expect(cleanResponse.statusCode).toBe(200);
        });
    });

    describe('Rate Limiting Integration', () => {
        test('should apply rate limits across different endpoints', async () => {
            // Make requests to different endpoints
            const healthPromises = Array.from({ length: 10 }, () =>
                app.inject({ method: 'GET', url: '/api/health' })
            );

            const cleanPromises = Array.from({ length: 5 }, (_, i) =>
                app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: `https://example.com/test${i}` }
                })
            );

            const [healthResponses, cleanResponses] = await Promise.all([
                Promise.all(healthPromises),
                Promise.all(cleanPromises)
            ]);

            // Health checks should mostly succeed (higher limit)
            const healthSuccessCount = healthResponses.filter(r => r.statusCode === 200).length;
            expect(healthSuccessCount).toBeGreaterThan(5);

            // Clean requests should all succeed (within limit)
            cleanResponses.forEach(response => {
                expect(response.statusCode).toBe(200);
            });
        });

        test('should track rate limits per endpoint independently', async () => {
            // Exhaust clean endpoint rate limit
            for (let i = 0; i < 100; i++) {
                const response = await app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: `https://example.com/test${i}` }
                });
                if (response.statusCode === 429) break;
            }

            // Health endpoint should still work
            const healthResponse = await app.inject({
                method: 'GET',
                url: '/api/health'
            });
            expect(healthResponse.statusCode).toBe(200);
        });
    });

    describe('Error Handling and Recovery', () => {
        test('should handle malformed requests gracefully', async () => {
            const malformedResponses = await Promise.all([
                app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: 'invalid json'
                }),
                app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: 'not-a-url' }
                }),
                app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: {}
                })
            ]);

            malformedResponses.forEach(response => {
                expect([400, 500]).toContain(response.statusCode);
            });
        });

        test('should maintain service availability during errors', async () => {
            // Make some requests that might cause errors
            const errorPromises = [
                app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: 'invalid-url' }
                }),
                app.inject({
                    method: 'GET',
                    url: '/api/strategies/non-existent'
                })
            ];

            await Promise.all(errorPromises);

            // Service should still be available
            const healthResponse = await app.inject({
                method: 'GET',
                url: '/api/health'
            });
            expect(healthResponse.statusCode).toBe(200);
        });
    });

    describe('Performance and Load Testing', () => {
        test('should handle concurrent requests efficiently', async () => {
            const concurrentRequests = Array.from({ length: 20 }, (_, i) =>
                app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: `https://example.com/concurrent-test-${i}` }
                })
            );

            const startTime = Date.now();
            const responses = await Promise.all(concurrentRequests);
            const endTime = Date.now();

            const successCount = responses.filter(r => r.statusCode === 200).length;
            expect(successCount).toBeGreaterThan(15); // Most should succeed
            expect(endTime - startTime).toBeLessThan(2000); // Should complete within 2 seconds
        });

        test('should maintain response times under load', async () => {
            const requests = Array.from({ length: 10 }, (_, i) => {
                const startTime = Date.now();
                return app.inject({
                    method: 'POST',
                    url: '/api/clean',
                    payload: { url: `https://example.com/load-test-${i}` }
                }).then((response: any) => ({
                    response,
                    duration: Date.now() - startTime
                }));
            });

            const results = await Promise.all(requests);

            results.forEach(({ response, duration }) => {
                expect(response.statusCode).toBe(200);
                expect(duration).toBeLessThan(500); // Each request should complete within 500ms
            });
        });
    });
});
