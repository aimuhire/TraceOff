import Fastify from 'fastify';
import { strategyRoutes } from '../routes/strategies';

// Mock environment variables
const originalEnv = process.env;
const validAdminSecret = 'a'.repeat(64);
const invalidAdminSecret = 'b'.repeat(64);

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
});

describe('Strategy CRUD Operations with Authentication', () => {
    let app: any;

    beforeEach(async () => {
        app = Fastify({
            logger: false, // Disable logging for tests
        });

        // Register strategy routes
        await app.register(strategyRoutes, { prefix: '/api' });

        await app.ready();
    });

    afterEach(async () => {
        if (app) {
            await app.close();
        }
    });

    const createValidStrategy = () => ({
        name: 'Test Strategy',
        matchers: [
            {
                type: 'exact',
                pattern: 'https://example.com',
                caseSensitive: false
            }
        ],
        paramPolicies: [
            {
                name: 'utm_source',
                action: 'deny',
                reason: 'Remove tracking parameter'
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
                template: 'example.com',
                required: true
            }
        ],
        notes: 'Test strategy for unit testing'
    });

    describe('POST /api/strategies (Create Strategy)', () => {
        test('should create strategy with valid admin token', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(201);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data).toHaveProperty('id');
            expect(data.data.name).toBe('Test Strategy');
            expect(data.data.version).toBe('1.0.0');
            expect(data.data.enabled).toBe(true);
            expect(data.data.priority).toBe(50);
        });

        test('should reject creation without admin token', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Authorization header required');
        });

        test('should reject creation with invalid admin token', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${invalidAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid admin token');
        });

        test('should reject creation with malformed authorization header', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': 'InvalidFormat token',
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid authorization format. Use Bearer token');
        });

        test('should reject creation with missing required fields', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: {
                    name: 'Incomplete Strategy'
                    // Missing required fields
                }
            });

            expect(response.statusCode).toBe(400);
        });

        test('should reject creation with invalid matcher type', async () => {
            const invalidStrategy = {
                ...createValidStrategy(),
                matchers: [
                    {
                        type: 'invalid_type',
                        pattern: 'https://example.com',
                        caseSensitive: false
                    }
                ]
            };

            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: invalidStrategy
            });

            expect(response.statusCode).toBe(400);
        });
    });

    describe('PUT /api/strategies/:id (Update Strategy)', () => {
        let createdStrategyId: string;

        beforeEach(async () => {
            // Create a strategy first
            const createResponse = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            const data = JSON.parse(createResponse.payload);
            createdStrategyId = data.data.id;
        });

        test('should update strategy with valid admin token', async () => {
            const updateData = {
                name: 'Updated Test Strategy',
                enabled: false,
                priority: 75,
                notes: 'Updated notes'
            };

            const response = await app.inject({
                method: 'PUT',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: updateData
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data.name).toBe('Updated Test Strategy');
            expect(data.data.enabled).toBe(false);
            expect(data.data.priority).toBe(75);
            expect(data.data.notes).toBe('Updated notes');
        });

        test('should reject update without admin token', async () => {
            const response = await app.inject({
                method: 'PUT',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Content-Type': 'application/json'
                },
                payload: { name: 'Updated Name' }
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Authorization header required');
        });

        test('should reject update with invalid admin token', async () => {
            const response = await app.inject({
                method: 'PUT',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Authorization': `Bearer ${invalidAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: { name: 'Updated Name' }
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid admin token');
        });

        test('should return 404 for non-existent strategy', async () => {
            const response = await app.inject({
                method: 'PUT',
                url: '/api/strategies/non-existent-id',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: { name: 'Updated Name' }
            });

            expect(response.statusCode).toBe(404);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Strategy not found');
        });

        test('should handle partial updates', async () => {
            const response = await app.inject({
                method: 'PUT',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: { enabled: false }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);
            expect(data.data.enabled).toBe(false);
            // Other fields should remain unchanged
            expect(data.data.name).toBe('Test Strategy');
        });
    });

    describe('DELETE /api/strategies/:id (Delete Strategy)', () => {
        let createdStrategyId: string;

        beforeEach(async () => {
            // Create a strategy first
            const createResponse = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`,
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            const data = JSON.parse(createResponse.payload);
            createdStrategyId = data.data.id;
        });

        test('should delete strategy with valid admin token', async () => {
            const response = await app.inject({
                method: 'DELETE',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`
                }
            });

            expect(response.statusCode).toBe(200);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(true);

            // Verify strategy is deleted
            const getResponse = await app.inject({
                method: 'GET',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`
                }
            });
            expect(getResponse.statusCode).toBe(404);
        });

        test('should reject deletion without admin token', async () => {
            const response = await app.inject({
                method: 'DELETE',
                url: `/api/strategies/${createdStrategyId}`
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Authorization header required');
        });

        test('should reject deletion with invalid admin token', async () => {
            const response = await app.inject({
                method: 'DELETE',
                url: `/api/strategies/${createdStrategyId}`,
                headers: {
                    'Authorization': `Bearer ${invalidAdminSecret}`
                }
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid admin token');
        });

        test('should return 404 for non-existent strategy', async () => {
            const response = await app.inject({
                method: 'DELETE',
                url: '/api/strategies/non-existent-id',
                headers: {
                    'Authorization': `Bearer ${validAdminSecret}`
                }
            });

            expect(response.statusCode).toBe(404);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Strategy not found');
        });
    });

    describe('Authentication Edge Cases', () => {
        test('should handle empty authorization header', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': '',
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Authorization header required');
        });

        test('should handle authorization header with only Bearer', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': 'Bearer',
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid authorization format. Use Bearer token');
        });

        test('should handle authorization header with wrong length token', async () => {
            const response = await app.inject({
                method: 'POST',
                url: '/api/strategies',
                headers: {
                    'Authorization': 'Bearer shorttoken',
                    'Content-Type': 'application/json'
                },
                payload: createValidStrategy()
            });

            expect(response.statusCode).toBe(401);
            const data = JSON.parse(response.payload);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Invalid token format');
        });
    });
});
