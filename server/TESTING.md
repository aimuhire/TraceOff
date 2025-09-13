# Testing Guide

This document provides comprehensive information about testing the TraceOff server application.

## Test Structure

The test suite is organized into several categories:

### Unit Tests

- **Admin Authentication** (`adminAuth.test.ts`) - Tests for admin authentication middleware
- **API Endpoints** (`apiEndpoints.test.ts`) - Tests for clean, preview, and health endpoints
- **Strategy CRUD** (`strategyCrud.test.ts`) - Tests for strategy management operations
- **Rate Limiting** (`rateLimiting.test.ts`) - Tests for rate limiting functionality
- **Health and Status** (`healthAndStatus.test.ts`) - Tests for health and status endpoints

### Integration Tests

- **Complete Flow** (`integration.test.ts`) - End-to-end tests covering the entire application workflow

## Running Tests

### All Tests

```bash
npm test
```

### Specific Test Categories

```bash
# Unit tests only
npm run test:unit

# Integration tests only
npm run test:integration

# Authentication tests only
npm run test:auth

# API endpoint tests only
npm run test:api

# Strategy CRUD tests only
npm run test:strategies

# Rate limiting tests only
npm run test:rate-limit

# Health and status tests only
npm run test:health
```

### Test Modes

```bash
# Watch mode (re-runs tests on file changes)
npm run test:watch

# Coverage report
npm run test:coverage

# CI mode (for continuous integration)
npm run test:ci

# Verbose output
npm run test:verbose

# Debug mode (with open handles detection)
npm run test:debug
```

## Test Configuration

### Jest Configuration

The test configuration is defined in `jest.config.js`:

- **Test Environment**: Node.js
- **Coverage Threshold**: 80% for all metrics
- **Timeout**: 10 seconds per test
- **Sequential Execution**: Tests run one at a time to avoid port conflicts
- **Coverage Reports**: Text, LCOV, HTML, and JSON formats

### Environment Variables

Tests use the following environment variables:

```bash
NODE_ENV=test
LOG_LEVEL=error
ADMIN_SECRET=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
RATE_LIMIT_CLEAN_MAX=100
RATE_LIMIT_CLEAN_WINDOW=1m
RATE_LIMIT_GENERAL_MAX=100
RATE_LIMIT_GENERAL_WINDOW=1m
RATE_LIMIT_HEALTH_MAX=1000
RATE_LIMIT_HEALTH_WINDOW=1m
RATE_LIMIT_ADMIN_MAX=50
RATE_LIMIT_ADMIN_WINDOW=1m
```

## Test Categories

### 1. Admin Authentication Tests

Tests the admin authentication middleware with various scenarios:

- ✅ Valid 64-character secret acceptance
- ✅ Missing authorization header rejection
- ✅ Invalid authorization format rejection
- ✅ Wrong secret rejection
- ✅ Token length validation
- ✅ Configuration validation
- ✅ Case sensitivity handling
- ✅ Edge cases (empty tokens, malformed headers)

### 2. API Endpoint Tests

Tests the core API functionality:

- ✅ URL cleaning with various platforms (YouTube, Instagram, Twitter)
- ✅ Preview functionality
- ✅ Health check endpoints
- ✅ Rate limit status endpoints
- ✅ Strategy listing and retrieval
- ✅ Error handling for malformed requests
- ✅ Input validation

### 3. Strategy CRUD Tests

Tests strategy management with authentication:

- ✅ Strategy creation with valid admin token
- ✅ Strategy creation without admin token (should fail)
- ✅ Strategy creation with invalid admin token (should fail)
- ✅ Strategy updates with authentication
- ✅ Strategy deletion with authentication
- ✅ Strategy retrieval (public access)
- ✅ Input validation and error handling
- ✅ Authentication edge cases

### 4. Rate Limiting Tests

Tests rate limiting functionality:

- ✅ Clean endpoint rate limiting
- ✅ Health endpoint rate limiting
- ✅ Admin endpoint rate limiting
- ✅ Per-IP rate limit tracking
- ✅ Rate limit status reporting
- ✅ Rate limit reset functionality
- ✅ Different limits for different endpoints
- ✅ Error handling during rate limiting

### 5. Health and Status Tests

Tests health and status endpoints:

- ✅ Basic health status
- ✅ Timestamp format validation
- ✅ Public access (no authentication required)
- ✅ Concurrent request handling
- ✅ Response format consistency
- ✅ Rate limit status reporting
- ✅ Performance under load
- ✅ Error handling

### 6. Integration Tests

Tests complete application workflows:

- ✅ Complete URL cleaning workflow
- ✅ Strategy management workflow (CRUD)
- ✅ Authentication and authorization flow
- ✅ Rate limiting integration
- ✅ Error handling and recovery
- ✅ Performance and load testing
- ✅ Concurrent request handling

## Test Utilities

The test suite includes global utilities accessible via `global.testUtils`:

### `createTestUrl(baseUrl, params)`

Creates test URLs with query parameters:

```javascript
const url = global.testUtils.createTestUrl("https://example.com", {
  utm_source: "test",
  utm_medium: "email",
});
```

### `waitFor(ms)`

Creates a promise that resolves after a specified delay:

```javascript
await global.testUtils.waitFor(100);
```

### `createMockHeaders(overrides)`

Creates mock request headers:

```javascript
const headers = global.testUtils.createMockHeaders({
  "user-agent": "test-bot",
});
```

### `createAdminHeaders(adminSecret)`

Creates admin authentication headers:

```javascript
const headers = global.testUtils.createAdminHeaders("your-secret");
```

## Coverage Reports

After running tests with coverage, reports are generated in the `coverage/` directory:

- **HTML Report**: `coverage/lcov-report/index.html` - Interactive coverage report
- **LCOV Report**: `coverage/lcov.info` - For CI/CD integration
- **JSON Report**: `coverage/coverage-final.json` - Machine-readable coverage data

## Best Practices

### Writing Tests

1. **Descriptive Names**: Use clear, descriptive test names that explain what is being tested
2. **Single Responsibility**: Each test should verify one specific behavior
3. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification phases
4. **Mock External Dependencies**: Use mocks for external services and dependencies
5. **Clean Up**: Ensure tests clean up after themselves

### Test Data

1. **Realistic Data**: Use realistic test data that mirrors production scenarios
2. **Edge Cases**: Test boundary conditions and edge cases
3. **Error Scenarios**: Test error handling and failure modes
4. **Performance**: Include performance tests for critical paths

### Maintenance

1. **Keep Tests Updated**: Update tests when changing functionality
2. **Remove Obsolete Tests**: Remove tests for deprecated features
3. **Monitor Coverage**: Maintain high test coverage for critical code paths
4. **Review Test Results**: Regularly review test results and fix failing tests

## Troubleshooting

### Common Issues

#### Port Conflicts

If tests fail with port conflicts, ensure tests run sequentially (they do by default).

#### Timeout Issues

If tests timeout, increase the timeout in `jest.config.js` or use `jest.setTimeout()` in specific tests.

#### Memory Leaks

Use `--detectOpenHandles` and `--forceExit` flags to detect and handle memory leaks.

#### Coverage Issues

Ensure all critical code paths are covered and adjust coverage thresholds as needed.

### Debug Mode

Run tests in debug mode for detailed information:

```bash
npm run test:debug
```

This will:

- Detect open handles
- Force exit after tests complete
- Provide detailed error information

## Continuous Integration

The test suite is designed to work in CI environments:

```bash
# CI test command
npm run test:ci
```

This command:

- Runs tests in CI mode
- Generates coverage reports
- Disables watch mode
- Uses appropriate timeouts for CI environments

## Performance Testing

The integration tests include performance tests that verify:

- Response times under normal load
- Behavior under concurrent requests
- Memory usage patterns
- Rate limiting effectiveness

These tests help ensure the application performs well in production environments.
