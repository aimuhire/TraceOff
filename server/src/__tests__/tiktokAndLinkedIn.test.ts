import Fastify from 'fastify';
import { cleanRoutes } from '../routes/clean';
import { strategyRoutes } from '../routes/strategies';
import { rateLimiterService } from '../middleware/rateLimiter';
// No resolver or network mocks; see conditional network test below

describe('Cleaning and redirects - TikTok & LinkedIn', () => {
  const originalEnv = { ...process.env };
  let app: any;

  beforeAll(async () => {
    process.env = {
      ...originalEnv,
      NODE_ENV: 'test',
      ADMIN_SECRET: 'a'.repeat(64),
    };

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

  test('TikTok: preserves handle/video id and removes tracking params', async () => {
    const input = 'https://www.tiktok.com/@tiktok/video/7550320089996823839?is_from_webapp=1&sender_device=pc&web_id=7531013992166032909';
    const res = await app.inject({ method: 'POST', url: '/api/clean', payload: { url: input } });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.payload);
    expect(body.success).toBe(true);
    const out = body.data.primary.url as string;
    expect(out).toBe('https://www.tiktok.com/@tiktok/video/7550320089996823839');
  });

  test('TikTok: jellyfam video strips tracking params', async () => {
    const input = 'https://www.tiktok.com/@jellyfam__/video/7535631609966677279?is_from_webapp=1&sender_device=pc';
    const res = await app.inject({ method: 'POST', url: '/api/clean', payload: { url: input } });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.payload);
    expect(body.success).toBe(true);
    const out = body.data.primary.url as string;
    expect(out).toBe('https://www.tiktok.com/@jellyfam__/video/7535631609966677279');
  });

  const networkOnly = process.env.ALLOW_NETWORK === 'true' ? test : test.skip;
  networkOnly('LinkedIn: shortener (real network, no mocks)', async () => {
    const input = 'https://lnkd.in/gUfrRGMD';
    const expected = 'https://rss.com/podcasts/deescovered-oasis/2082075/';

    const res = await app.inject({ method: 'POST', url: '/api/clean', payload: { url: input } });
    expect(res.statusCode).toBe(200);
    const body = JSON.parse(res.payload);
    expect(body.success).toBe(true);
    const out = body.data.primary.url as string;
    expect(out).toBe(expected);
  });
});
