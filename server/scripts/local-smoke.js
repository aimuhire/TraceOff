/*
  Local smoke test without binding a port.
  Builds a Fastify app, registers middleware + routes, then injects requests.
*/
/* eslint-disable no-console */
const Fastify = require('fastify');

async function main() {
  const app = Fastify({ logger: false });

  // Load compiled JS from dist
  const rateLimiter = require('../dist/middleware/rateLimiter.js');
  const cleanRoutes = require('../dist/routes/clean.js');
  const strategyRoutes = require('../dist/routes/strategies.js');
  const rateLimitConfig = require('../dist/config/rateLimit.js');

  // Env for admin routes
  process.env.ADMIN_SECRET = 'a'.repeat(64);
  process.env.NODE_ENV = 'test'; // bypass some rate limiters as in tests

  // Configure rate limiter
  const cfg = rateLimitConfig.getRateLimitConfig();
  rateLimiter.rateLimiterService.updateConfig(cfg);
  await rateLimiter.rateLimiterService.registerRateLimiters(app);

  // Register routes under /api
  await app.register(cleanRoutes.cleanRoutes, { prefix: '/api' });
  await app.register(strategyRoutes.strategyRoutes, { prefix: '/api' });
  await app.ready();

  // Health
  const res = await app.inject({ method: 'GET', url: '/api/health' });
  console.log('GET /api/health', res.statusCode, res.payload);

  // Clean
  const res2 = await app.inject({
    method: 'POST',
    url: '/api/clean',
    headers: { 'content-type': 'application/json' },
    payload: { url: 'https://example.com?utm_source=test' },
  });
  console.log('POST /api/clean', res2.statusCode, res2.payload.substring(0, 200) + '...');

  await app.close();
}

main().catch((e) => { console.error(e); process.exit(1); });

