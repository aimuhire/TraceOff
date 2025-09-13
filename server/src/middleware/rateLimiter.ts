import { FastifyInstance, FastifyRequest } from 'fastify';
import rateLimit from '@fastify/rate-limit';
import Redis from 'ioredis';
import crypto from 'crypto';

// Mock rate limiter for tests
class MockRateLimiter {
    private requestCounts = new Map<string, { count: number; resetTime: number }>();
    private config: RateLimitConfig;
    private blockedRequests = new Set<string>(); // For testing - can be controlled

    constructor(config: RateLimitConfig) {
        this.config = config;
    }

    shouldBlockRequest(request: FastifyRequest): boolean {
        const key = this.getRequestKey(request);
        const endpointType = this.getEndpointType(request.url);
        const limit = this.config[endpointType].max;
        const timeWindow = this.parseTimeWindow(this.config[endpointType].timeWindow);

        // Check if this specific request should be blocked (for testing)
        if (this.blockedRequests.has(key)) {
            return true;
        }

        // Get current rate limit data
        const now = Date.now();
        let rateLimitData = this.requestCounts.get(key);

        // Reset if time window has expired
        if (!rateLimitData || now > rateLimitData.resetTime) {
            rateLimitData = { count: 0, resetTime: now + timeWindow };
        }

        // Check if rate limit exceeded
        if (rateLimitData.count >= limit) {
            return true;
        }

        // Increment counter
        rateLimitData.count++;
        this.requestCounts.set(key, rateLimitData);
        return false;
    }

    createErrorResponse(request: FastifyRequest) {
        const endpointType = this.getEndpointType(request.url);
        const limit = this.config[endpointType].max;
        const timeWindow = this.config[endpointType].timeWindow;

        return {
            success: false,
            error: 'Rate limit exceeded',
            message: `Too many requests. Limit: ${limit} requests per ${timeWindow}`,
            limit,
            remaining: 0,
            resetTime: new Date(Date.now() + this.parseTimeWindow(timeWindow)).toISOString(),
            timestamp: new Date().toISOString(),
        };
    }

    getRateLimitHeaders(request: FastifyRequest) {
        const endpointType = this.getEndpointType(request.url);
        const limit = this.config[endpointType].max;
        const key = this.getRequestKey(request);
        const rateLimitData = this.requestCounts.get(key);
        const currentCount = rateLimitData ? rateLimitData.count : 0;

        return {
            'X-RateLimit-Limit': limit,
            'X-RateLimit-Remaining': Math.max(0, limit - currentCount),
            'X-RateLimit-Reset': rateLimitData ? new Date(rateLimitData.resetTime).toISOString() : new Date(Date.now() + this.parseTimeWindow(this.config[endpointType].timeWindow)).toISOString(),
        };
    }

    private getRequestKey(request: FastifyRequest): string {
        const ip = request.ip || 'unknown';
        const endpointType = this.getEndpointType(request.url);
        return `${endpointType}:${ip}`;
    }

    private getEndpointType(url: string): keyof RateLimitConfig {
        if (url.includes('/api/clean')) return 'clean';
        if (url.includes('/api/health')) return 'health';
        if (url.includes('/api/strategies')) return 'admin';
        return 'general';
    }

    private parseTimeWindow(timeWindow: string): number {
        const match = timeWindow.match(/^(\d+)([smhd])$/);
        if (!match) return 60000; // Default 1 minute

        const value = parseInt(match[1], 10);
        const unit = match[2];

        switch (unit) {
            case 's': return value * 1000;
            case 'm': return value * 60 * 1000;
            case 'h': return value * 60 * 60 * 1000;
            case 'd': return value * 24 * 60 * 60 * 1000;
            default: return 60000;
        }
    }

    // Test control methods
    clearAll() {
        this.requestCounts.clear();
        this.blockedRequests.clear();
    }

    // For testing - force block a specific request
    blockRequest(key: string) {
        this.blockedRequests.add(key);
    }

    // For testing - unblock a specific request
    unblockRequest(key: string) {
        this.blockedRequests.delete(key);
    }

    // For testing - get current count
    getRequestCount(key: string): number {
        const rateLimitData = this.requestCounts.get(key);
        return rateLimitData ? rateLimitData.count : 0;
    }
}

export interface RateLimitConfig {
    // General API limits
    general: {
        max: number;
        timeWindow: string;
    };
    // Clean endpoint limits (more restrictive)
    clean: {
        max: number;
        timeWindow: string;
    };
    // Health check limits (very permissive)
    health: {
        max: number;
        timeWindow: string;
    };
    // Admin/strategies limits
    admin: {
        max: number;
        timeWindow: string;
    };
}

export const defaultRateLimitConfig: RateLimitConfig = {
    general: {
        max: 100, // 100 requests
        timeWindow: '1m', // per minute
    },
    clean: {
        max: 20, // 20 requests
        timeWindow: '1m', // per minute
    },
    health: {
        max: 1000, // 1000 requests
        timeWindow: '1m', // per minute
    },
    admin: {
        max: 50, // 50 requests
        timeWindow: '1m', // per minute
    },
};

export class RateLimiterService {
    private redis?: Redis | undefined;
    private config: RateLimitConfig;

    constructor(config: RateLimitConfig = defaultRateLimitConfig) {
        this.config = config;
        if (process.env.NODE_ENV === 'test') {
            // Skip initialization in test mode - rate limiting is disabled
            console.log('🧪 Test mode: Rate limiter initialization skipped');
        } else {
            this.initializeRedis();
        }
    }

    private initializeRedis() {
        // Only use Redis if REDIS_URL is explicitly provided and not empty
        const redisUrl = process.env.REDIS_URL?.trim();
        if (redisUrl && redisUrl !== '') {
            try {
                this.redis = new Redis(redisUrl, {
                    maxRetriesPerRequest: 3,
                    lazyConnect: true,
                    enableReadyCheck: false,
                });

                this.redis.on('error', (err) => {
                    console.warn('Redis connection error:', err.message);
                    this.redis = undefined; // Fall back to memory store
                });

                this.redis.on('connect', () => {
                    console.log('✅ Redis connected for rate limiting');
                });

                this.redis.on('ready', () => {
                    console.log('✅ Redis ready for rate limiting');
                });
            } catch (error) {
                console.warn('Failed to initialize Redis, falling back to memory store:', error);
                this.redis = undefined;
            }
        } else {
            console.log('ℹ️  Using memory store for rate limiting (Redis not configured)');
        }
    }


    async registerRateLimiters(fastify: FastifyInstance) {
        // In test mode, use a mock rate limiter
        if (process.env.NODE_ENV === 'test') {
            console.log('🧪 Test mode: Using mock rate limiter for tests');
            this.registerMockRateLimiters(fastify);
            return;
        }

        // Use Redis or memory store
        const store = this.redis;

        // General API rate limiter
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('general'),
            max: this.config.general.max,
            timeWindow: this.parseTimeWindow(this.config.general.timeWindow),
            redis: store,
            skipOnError: true, // Don't fail if rate limiter has issues
        });

        // Clean endpoint rate limiter (more restrictive)
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('clean'),
            max: this.config.clean.max,
            timeWindow: this.parseTimeWindow(this.config.clean.timeWindow),
            redis: store,
            errorResponseBuilder: this.createErrorResponse('clean'),
            skipOnError: true,
        });

        // Health check rate limiter (very permissive)
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('health'),
            max: this.config.health.max,
            timeWindow: this.parseTimeWindow(this.config.health.timeWindow),
            redis: store,
            errorResponseBuilder: this.createErrorResponse('health'),
            skipOnError: true,
        });

        // Admin/strategies rate limiter
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('admin'),
            max: this.config.admin.max,
            timeWindow: this.parseTimeWindow(this.config.admin.timeWindow),
            redis: store,
            errorResponseBuilder: this.createErrorResponse('admin'),
            skipOnError: true,
        });
    }

    private registerMockRateLimiters(fastify: FastifyInstance) {
        // Mock rate limiter for tests - can be controlled via patches
        const mockRateLimiter = new MockRateLimiter(this.config);

        fastify.addHook('onRequest', async (request, reply) => {
            const shouldBlock = mockRateLimiter.shouldBlockRequest(request);

            if (shouldBlock) {
                const errorResponse = mockRateLimiter.createErrorResponse(request);
                return reply.status(429).send(errorResponse);
            }

            // Add rate limit headers
            const headers = mockRateLimiter.getRateLimitHeaders(request);
            Object.entries(headers).forEach(([key, value]) => {
                reply.header(key, value);
            });
        });

        // Store reference for clearing
        (this as Record<string, unknown>).mockRateLimiter = mockRateLimiter;
    }

    private getKeyGenerator(type: keyof RateLimitConfig) {
        return (request: FastifyRequest) => {
            // Get client IP as the only identifier
            const ip = this.getClientIP(request) || 'unknown';

            // Hash the IP to avoid collisions and prevent leaking raw IPs
            const hash = crypto.createHash('sha256').update(ip).digest('hex');

            // Use unique test prefix for each test run to ensure isolation
            const testPrefix = process.env.NODE_ENV === 'test'
                ? (process.env.TEST_ID ? `${process.env.TEST_ID}-` : 'test-')
                : '';

            return `rate-limit:${testPrefix}${type}:${hash}`;
        };
    }

    private getClientIP(request: FastifyRequest): string {
        // Check for forwarded IP first (for reverse proxies)
        const forwarded = request.headers['x-forwarded-for'];
        if (forwarded) {
            const ips = Array.isArray(forwarded) ? forwarded[0] : forwarded;
            return ips.split(',')[0].trim();
        }

        // Check for real IP header
        const realIP = request.headers['x-real-ip'];
        if (realIP) {
            return Array.isArray(realIP) ? realIP[0] : realIP;
        }

        // Fall back to connection remote address
        return request.ip || 'unknown';
    }

    private createErrorResponse(_type: keyof RateLimitConfig) {
        return (_request: FastifyRequest, context: any) => {
            const retryAfter = Math.round(context.timeWindow / 1000);
            const limit = context.max;
            const remaining = Math.max(0, limit - context.current);

            return {
                success: false,
                error: 'Rate limit exceeded',
                message: `Too many requests. Limit: ${limit} requests per ${context.timeWindow}ms`,
                retryAfter,
                limit,
                remaining,
                resetTime: new Date(Date.now() + context.timeWindow).toISOString(),
                timestamp: new Date().toISOString(),
            };
        };
    }

    // Method to get current rate limit status for a client
    async getRateLimitStatus(request: FastifyRequest, type: keyof RateLimitConfig) {
        if (!this.redis) {
            // In memory mode, we can't get exact status, but we can return the configured limits
            return {
                limit: this.config[type].max,
                remaining: this.config[type].max, // Approximate - actual remaining would need to be tracked
                resetTime: new Date(Date.now() + this.parseTimeWindow(this.config[type].timeWindow)).toISOString(),
                mode: 'memory',
            };
        }

        try {
            const key = this.getKeyGenerator(type)(request);
            const data = await this.redis.get(key);

            if (!data) {
                return {
                    limit: this.config[type].max,
                    remaining: this.config[type].max,
                    resetTime: new Date(Date.now() + this.parseTimeWindow(this.config[type].timeWindow)).toISOString(),
                    mode: 'redis',
                };
            }

            const parsed = JSON.parse(data);
            return {
                limit: this.config[type].max,
                remaining: Math.max(0, this.config[type].max - parsed.total),
                resetTime: new Date(parsed.ttl * 1000).toISOString(),
                mode: 'redis',
            };
        } catch (error) {
            console.warn('Failed to get rate limit status:', error);
            return null;
        }
    }

    private parseTimeWindow(timeWindow: string): number {
        const match = timeWindow.match(/^(\d+)([smhd])$/);
        if (!match) {
            return 60000; // Default to 1 minute
        }

        const value = parseInt(match[1]);
        const unit = match[2];

        switch (unit) {
            case 's': return value * 1000;
            case 'm': return value * 60 * 1000;
            case 'h': return value * 60 * 60 * 1000;
            case 'd': return value * 24 * 60 * 60 * 1000;
            default: return 60000;
        }
    }

    // Method to update rate limit configuration
    updateConfig(newConfig: Partial<RateLimitConfig>) {
        this.config = { ...this.config, ...newConfig };
    }

    // Method to get current configuration
    getConfig(): RateLimitConfig {
        return { ...this.config };
    }

    // Method to get mock rate limiter for testing
    getMockRateLimiter() {
        if (process.env.NODE_ENV !== 'test') {
            throw new Error('Mock rate limiter only available in test mode');
        }
        return (this as Record<string, unknown>).mockRateLimiter;
    }


    // Method to clear all rate limit data (for testing)
    async clearAll() {
        if (process.env.NODE_ENV === 'test') {
            // Clear mock rate limiter state
            const mockRateLimiter = (this as Record<string, unknown>).mockRateLimiter as { clearAll: () => void } | undefined;
            if (mockRateLimiter) {
                mockRateLimiter.clearAll();
                console.log('✅ [clearAll] Mock rate limiter cleared');
            }
            return;
        } else if (this.redis) {
            // Clear all rate limit keys from Redis
            const keys = await this.redis.keys('rate-limit:*');
            if (keys.length > 0) {
                await this.redis.del(...keys);
            }
        } else {
            // For memory store, we can't easily clear individual entries
            // This is a limitation of the @fastify/rate-limit plugin
            console.warn('Cannot clear rate limits with memory store. Consider using Redis for testing.');
        }
    }

    // Cleanup method
    async close() {
        if (this.redis) {
            await this.redis.quit();
        }
    }
}

// Export a singleton instance
export const rateLimiterService = new RateLimiterService();
