module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src"],
  testMatch: ["**/__tests__/**/*.test.ts", "**/?(*.)+(spec|test).ts"],
  transform: {
    "^.+\\.ts$": "ts-jest",
  },
  transformIgnorePatterns: ["node_modules/(?!(nanoid)/)"],
  moduleNameMapping: {
    "^nanoid$": "<rootDir>/src/__tests__/__mocks__/nanoid.js",
  },
  collectCoverageFrom: [
    "src/**/*.ts",
    "!src/**/*.d.ts",
    "!src/**/__tests__/**",
    "!src/**/index.ts", // Exclude main entry point from coverage
  ],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html", "json"],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  setupFilesAfterEnv: ["<rootDir>/src/__tests__/setup.ts"],
  testTimeout: 10000,
  maxWorkers: 1, // Run tests sequentially to avoid port conflicts
  verbose: false,
  detectOpenHandles: true,
  forceExit: true,
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
  // Test environment variables
  testEnvironmentOptions: {
    NODE_ENV: "test",
    LOG_LEVEL: "error", // Reduce log noise during tests
  },
  // Ignore patterns
  testPathIgnorePatterns: ["/node_modules/", "/dist/", "/coverage/"],
  // Coverage ignore patterns
  coveragePathIgnorePatterns: [
    "/node_modules/",
    "/dist/",
    "/coverage/",
    "/src/__tests__/",
    "/src/index.ts",
  ],
};
