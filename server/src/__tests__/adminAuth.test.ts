import { createAdminAuthMiddleware } from '../middleware/adminAuth';

// Mock FastifyRequest and FastifyReply
const createMockRequest = (headers: Record<string, string> = {}): any => ({
    headers,
    ip: '127.0.0.1',
    url: '/admin/test',
});

const createMockReply = (): any => {
    let statusCode = 200;
    let responseBody: any = null;

    return {
        status: (code: number) => {
            statusCode = code;
            return { send: (body: any) => { responseBody = body; return {}; } };
        },
        send: (body: any) => {
            responseBody = body;
            return {};
        },
        getStatusCode: () => statusCode,
        getResponseBody: () => responseBody,
    };
};

describe('Admin Authentication Middleware', () => {
    const validSecret = 'a'.repeat(64);
    const invalidSecret = 'b'.repeat(64);
    const shortSecret = 'short';

    test('should accept valid 64-character secret', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: `Bearer ${validSecret}`
        });
        const reply = createMockReply();

        let error: Error | null = null;
        try {
            await middleware(request, reply);
        } catch (err) {
            error = err as Error;
        }

        expect(error).toBeNull();
    });

    test('should reject missing authorization header', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest();
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Authorization header required'
        });
    });

    test('should reject invalid authorization format', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: 'InvalidFormat token'
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Invalid authorization format. Use Bearer token'
        });
    });

    test('should reject wrong secret', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: `Bearer ${invalidSecret}`
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Invalid admin token'
        });
    });

    test('should reject token with wrong length', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: 'Bearer shorttoken'
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Invalid token format'
        });
    });

    test('should reject when admin secret is not configured', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: '' });
        const request = createMockRequest({
            authorization: `Bearer ${validSecret}`
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(500);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Admin authentication not configured'
        });
    });

    test('should reject when admin secret is wrong length', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: shortSecret });
        const request = createMockRequest({
            authorization: `Bearer ${validSecret}`
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(500);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Admin authentication not configured'
        });
    });

    test('should handle case sensitivity correctly', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: `bearer ${validSecret}` // lowercase 'bearer'
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Invalid authorization format. Use Bearer token'
        });
    });

    test('should handle empty bearer token', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: 'Bearer '
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Invalid token format'
        });
    });

    test('should handle malformed authorization header', async () => {
        const middleware = createAdminAuthMiddleware({ adminSecret: validSecret });
        const request = createMockRequest({
            authorization: 'Bearer token with spaces'
        });
        const reply = createMockReply();

        await middleware(request, reply);

        expect(reply.getStatusCode()).toBe(401);
        expect(reply.getResponseBody()).toMatchObject({
            success: false,
            error: 'Invalid token format'
        });
    });
});
