import { FastifyRequest } from 'fastify';

/**
 * Privacy-focused logging utility
 * Ensures no sensitive user data is logged
 */

export interface SafeLogData {
    route?: string;
    phase?: string;
    requestId?: string;
    statusCode?: number;
    responseTime?: number;
    error?: string;
    // Never include: url, strategyId, domain, user data, etc.
}

/**
 * Sanitize log data to remove any potentially sensitive information
 */
export function sanitizeLogData(data: Record<string, unknown>): SafeLogData {
    const safeData: SafeLogData = {};

    // Only allow safe fields
    const allowedFields = [
        'route',
        'phase',
        'requestId',
        'statusCode',
        'responseTime',
        'error',
        'method',
        'userAgent',
        'ip',
    ];

    for (const [key, value] of Object.entries(data)) {
        if (allowedFields.includes(key) && value !== undefined && value !== null) {
            (safeData as Record<string, unknown>)[key] = value;
        }
    }

    return safeData;
}

/**
 * Extract safe request information for logging
 */
export function getSafeRequestInfo(request: FastifyRequest) {
    return {
        method: request.method,
        userAgent: request.headers['user-agent'] || 'unknown',
        ip: request.ip || 'unknown',
        requestId: (request as unknown as Record<string, unknown>).id as string | undefined,
    };
}

/**
 * Log levels for different types of information
 */
export const LOG_LEVELS = {
    ERROR: 'error',
    WARN: 'warn',
    INFO: 'info',
    DEBUG: 'debug',
} as const;

/**
 * Safe logging wrapper that ensures no sensitive data is logged
 */
export class SafeLogger {
    private logger: {
        info: (data: SafeLogData, message: string) => void;
        warn: (data: SafeLogData, message: string) => void;
        error: (data: SafeLogData, message: string) => void;
        debug: (data: SafeLogData, message: string) => void;
    };

    constructor(logger: {
        info: (data: SafeLogData, message: string) => void;
        warn: (data: SafeLogData, message: string) => void;
        error: (data: SafeLogData, message: string) => void;
        debug: (data: SafeLogData, message: string) => void;
    }) {
        this.logger = logger;
    }

    info(data: Record<string, unknown>, message: string) {
        this.logger.info(sanitizeLogData(data), message);
    }

    warn(data: Record<string, unknown>, message: string) {
        this.logger.warn(sanitizeLogData(data), message);
    }

    error(data: Record<string, unknown>, message: string) {
        this.logger.error(sanitizeLogData(data), message);
    }

    debug(data: Record<string, unknown>, message: string) {
        this.logger.debug(sanitizeLogData(data), message);
    }
}

/**
 * Create a safe logger instance
 */
export function createSafeLogger(logger: {
    info: (data: SafeLogData, message: string) => void;
    warn: (data: SafeLogData, message: string) => void;
    error: (data: SafeLogData, message: string) => void;
    debug: (data: SafeLogData, message: string) => void;
}): SafeLogger {
    return new SafeLogger(logger);
}
