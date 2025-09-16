import Fastify from 'fastify';
import { cleanRoutes } from '../routes/clean';
import { strategyRoutes } from '../routes/strategies';
import { rateLimiterService } from '../middleware/rateLimiter';

describe('Pinterest shortener - Network', () => {
    const networkOnly = process.env.ALLOW_NETWORK === 'true' ? test : test.skip;
    let app: any;

    beforeAll(async () => {
        process.env.NODE_ENV = 'test';
        process.env.ADMIN_SECRET = 'a'.repeat(64);

        app = Fastify({ logger: false });
        const { getRateLimitConfig } = await import('../config/rateLimit');
        rateLimiterService.updateConfig(getRateLimitConfig());
        await rateLimiterService.registerRateLimiters(app);
        await app.register(cleanRoutes, { prefix: '/api' });
        await app.register(strategyRoutes, { prefix: '/api' });
        await app.ready();
    });

    afterAll(async () => {
        if (app) await app.close();
        rateLimiterService.clearAll();
    });

    networkOnly('pin.it resolves to canonical Pinterest pin URL (regex normalization, no HTML needed)', async () => {
        const input = 'https://pin.it/46SsDHkyg';
        const expected = 'https://www.pinterest.com/pin/19281104652367433/';

        const res = await app.inject({ method: 'POST', url: '/api/clean', payload: { url: input } });
        expect(res.statusCode).toBe(200);
        const body = JSON.parse(res.payload);
        expect(body.success).toBe(true);
        const out = body.data.primary.url as string;
        expect(out).toBe(expected);
    });
});


