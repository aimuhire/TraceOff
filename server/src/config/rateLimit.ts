import { RateLimitConfig } from '../middleware/rateLimiter';

// Environment-based rate limit configuration
export function getRateLimitConfig(): RateLimitConfig {
    const isDevelopment = process.env.NODE_ENV === 'development';
    const isProduction = process.env.NODE_ENV === 'production';

    // Base configuration
    const baseConfig: RateLimitConfig = {
        general: {
            max: parseInt(process.env.RATE_LIMIT_GENERAL_MAX || '100', 10),
            timeWindow: process.env.RATE_LIMIT_GENERAL_WINDOW || '1m',
        },
        clean: {
            max: parseInt(process.env.RATE_LIMIT_CLEAN_MAX || '20', 10),
            timeWindow: process.env.RATE_LIMIT_CLEAN_WINDOW || '1m',
        },
        health: {
            max: parseInt(process.env.RATE_LIMIT_HEALTH_MAX || '1000', 10),
            timeWindow: process.env.RATE_LIMIT_HEALTH_WINDOW || '1m',
        },
        admin: {
            max: parseInt(process.env.RATE_LIMIT_ADMIN_MAX || '50', 10),
            timeWindow: process.env.RATE_LIMIT_ADMIN_WINDOW || '1m',
        },
    };

    // Development overrides (more permissive)
    if (isDevelopment) {
        return {
            general: {
                max: 1000,
                timeWindow: '1m',
            },
            clean: {
                max: 100,
                timeWindow: '1m',
            },
            health: {
                max: 10000,
                timeWindow: '1m',
            },
            admin: {
                max: 500,
                timeWindow: '1m',
            },
        };
    }

    // Production overrides (more restrictive)
    if (isProduction) {
        return {
            general: {
                max: 50,
                timeWindow: '1m',
            },
            clean: {
                max: 10,
                timeWindow: '1m',
            },
            health: {
                max: 100,
                timeWindow: '1m',
            },
            admin: {
                max: 20,
                timeWindow: '1m',
            },
        };
    }

    return baseConfig;
}

// Rate limit tiers for different user types
export const RATE_LIMIT_TIERS = {
    FREE: {
        general: { max: 20, timeWindow: '1m' },
        clean: { max: 5, timeWindow: '1m' },
        health: { max: 100, timeWindow: '1m' },
        admin: { max: 10, timeWindow: '1m' },
    },
    PREMIUM: {
        general: { max: 100, timeWindow: '1m' },
        clean: { max: 20, timeWindow: '1m' },
        health: { max: 500, timeWindow: '1m' },
        admin: { max: 50, timeWindow: '1m' },
    },
    ENTERPRISE: {
        general: { max: 500, timeWindow: '1m' },
        clean: { max: 100, timeWindow: '1m' },
        health: { max: 1000, timeWindow: '1m' },
        admin: { max: 200, timeWindow: '1m' },
    },
} as const;

// Rate limit bypass for specific IPs or patterns
export const RATE_LIMIT_BYPASS = {
    // IP addresses that bypass rate limiting (admin, monitoring, etc.)
    whitelistIPs: (process.env.RATE_LIMIT_WHITELIST_IPS || '').split(',').filter(Boolean),

    // User agents that bypass rate limiting
    whitelistUserAgents: [
        'health-check',
        'monitoring',
        'uptime-robot',
    ],

    // Check if request should bypass rate limiting
    shouldBypass(request: { headers: Record<string, string | string[]>; ip?: string }): boolean {
        const ip = getClientIP(request);
        const userAgent = request.headers['user-agent'] || '';

        // Check IP whitelist
        if (this.whitelistIPs.includes(ip)) {
            return true;
        }

        // Check user agent whitelist
        if (this.whitelistUserAgents.some(agent => userAgent.includes(agent))) {
            return true;
        }

        return false;
    },
};

// Helper function to get client IP
function getClientIP(request: { headers: Record<string, string | string[]>; ip?: string }): string {
    const forwarded = request.headers['x-forwarded-for'];
    if (forwarded) {
        const ips = Array.isArray(forwarded) ? forwarded[0] : forwarded;
        return ips.split(',')[0].trim();
    }

    const realIP = request.headers['x-real-ip'];
    if (realIP) {
        return Array.isArray(realIP) ? realIP[0] : realIP;
    }

    return request.ip || 'unknown';
}
