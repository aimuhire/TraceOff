// Test setup file
// This file runs before each test file

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.LOG_LEVEL = 'error';
process.env.ADMIN_SECRET = 'a'.repeat(64);

// Mock console methods to reduce noise during tests
const originalConsole = { ...console };

beforeAll(() => {
    // Suppress console output during tests unless explicitly needed
    console.log = jest.fn();
    console.info = jest.fn();
    console.warn = jest.fn();
    console.error = jest.fn();
});

afterAll(() => {
    // Restore original console methods
    Object.assign(console, originalConsole);
});

// Global test timeout
jest.setTimeout(10000);

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
});

// Clean up after each test
afterEach(() => {
    // Clear all timers
    jest.clearAllTimers();

    // Clear all mocks
    jest.clearAllMocks();

    // Reset modules if needed
    jest.resetModules();
});

// Test utilities (exported for use in tests)
export const testUtils = {
    // Helper to create test URLs
    createTestUrl: (baseUrl: string, params: Record<string, string> = {}) => {
        const url = new URL(baseUrl);
        Object.entries(params).forEach(([key, value]) => {
            url.searchParams.set(key, value);
        });
        return url.toString();
    },

    // Helper to wait for async operations
    waitFor: (ms: number) => new Promise(resolve => setTimeout(resolve, ms)),

    // Helper to create mock request headers
    createMockHeaders: (overrides: Record<string, string> = {}) => ({
        'content-type': 'application/json',
        'user-agent': 'test-agent',
        ...overrides
    }),

    // Helper to create admin headers
    createAdminHeaders: (adminSecret: string = 'a'.repeat(64)) => ({
        'authorization': `Bearer ${adminSecret}`,
        'content-type': 'application/json'
    })
};
