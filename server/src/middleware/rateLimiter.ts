import { FastifyInstance, FastifyRequest } from 'fastify';
import rateLimit from '@fastify/rate-limit';
import Redis from 'ioredis';

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
        this.initializeRedis();
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
        // General API rate limiter
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('general'),
            max: this.config.general.max,
            timeWindow: this.config.general.timeWindow,
            redis: this.redis,
            errorResponseBuilder: this.createErrorResponse('general'),
            skipOnError: true, // Don't fail if rate limiter has issues
        });

        // Clean endpoint rate limiter (more restrictive)
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('clean'),
            max: this.config.clean.max,
            timeWindow: this.config.clean.timeWindow,
            redis: this.redis,
            errorResponseBuilder: this.createErrorResponse('clean'),
            skipOnError: true,
        });

        // Health check rate limiter (very permissive)
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('health'),
            max: this.config.health.max,
            timeWindow: this.config.health.timeWindow,
            redis: this.redis,
            errorResponseBuilder: this.createErrorResponse('health'),
            skipOnError: true,
        });

        // Admin/strategies rate limiter
        await fastify.register(rateLimit, {
            keyGenerator: this.getKeyGenerator('admin'),
            max: this.config.admin.max,
            timeWindow: this.config.admin.timeWindow,
            redis: this.redis,
            errorResponseBuilder: this.createErrorResponse('admin'),
            skipOnError: true,
        });
    }

    private getKeyGenerator(type: keyof RateLimitConfig) {
        return (request: FastifyRequest) => {
            // Get client IP
            const ip = this.getClientIP(request);

            // Get user agent for additional identification
            const userAgent = request.headers['user-agent'] || 'unknown';

            // Create a hash of IP + User Agent for better identification
            const identifier = `${ip}:${Buffer.from(userAgent).toString('base64').slice(0, 16)}`;

            return `${type}:${identifier}`;
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

    // Method to clear all rate limit data (for testing)
    async clearAll() {
        if (this.redis) {
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
