# TraceOff

<div align="center">

**Share links without trackers**

[![Deploy to Vercel](https://img.shields.io/badge/Deploy%20to-Vercel-black?style=for-the-badge&logo=vercel)](https://vercel.com/new/clone?repository-url=https://github.com/aimuhire/traceoff)
[![Tests](https://github.com/aimuhire/traceoff/workflows/Test%20Suite/badge.svg)](https://github.com/aimuhire/traceoff/actions)
[![Deploy](https://github.com/aimuhire/traceoff/workflows/Test%20and%20Deploy/badge.svg)](https://github.com/aimuhire/traceoff/actions)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org)

A comprehensive link cleaning solution that removes tracking parameters and provides clean, shareable links. Built with Flutter for mobile and Node.js/TypeScript for the backend.

[🚀 Live Demo](https://traceoff.vercel.app) • [📱 Mobile App](#mobile-app) • [🔧 API Documentation](#api-endpoints) • [📖 Documentation](#documentation)

</div>

## Features

### 🧹 Link Cleaning

- **Domain-specific strategies** for major platforms (Instagram, YouTube, Twitter, TikTok, etc.)
- **Generic fallback** for unknown domains
- **Alternative results** with different cleaning approaches
- **Confidence scoring** for each cleaned link
- **Redirect resolution** with safety limits

### 📱 Mobile App (Flutter)

- **Share sheet integration** - clean links directly from other apps
- **History & favorites** - save and organize cleaned links
- **Settings** - customize behavior and appearance
- **Dark/light theme** support
- **Offline history** with local SQLite storage

### 🖥️ Admin Web UI

- **Strategy management** - create, edit, and manage cleaning rules
- **Live testing** - test links against different strategies
- **Performance metrics** - monitor cleaning performance
- **Import/export** - backup and restore strategies
- **Secure access** - protected by 64-character admin secret

### 🔧 Backend API (Node.js/TypeScript)

- **RESTful API** with Fastify
- **Modular strategy engine** with pluggable rules
- **Real-time strategy updates**
- **Comprehensive logging** and monitoring

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ and npm
- **Flutter** 3.10+ (for mobile development)
- **Android Studio** / **Xcode** (for mobile development)

### Local Development

#### 1. Clone the Repository

```bash
git clone https://github.com/aimuhire/traceoff.git
cd traceoff
```

#### 2. Install Dependencies

```bash
# Install root dependencies
npm install

# Install server dependencies
cd server && npm install

# Install mobile dependencies
cd ../mobile && flutter pub get
```

#### 3. Start Development Servers

```bash
# Start both server and mobile (from root)
npm run dev

# Or start individually:
# Server only
cd server && npm run dev

# Mobile only (in another terminal)
cd mobile && flutter run
```

#### 4. Configure Admin Authentication

The admin UI and strategy management endpoints are protected by a 64-character secret key.

**Generate an admin secret:**

```bash
cd server
node scripts/generate-admin-secret.js
```

**Add to your environment:**

```bash
# Copy the generated secret to your .env file
echo "ADMIN_SECRET=your-64-character-secret-here" >> .env
```

**Access protected endpoints:**

- Include the secret in the `Authorization` header: `Bearer your-64-character-secret-here`
- Or access the admin UI at `http://localhost:3000/admin` (will prompt for authentication)

#### 5. Access the Application

- **API Server**: `http://localhost:3000`
- **Admin UI**: `http://localhost:3000/admin` (requires authentication)
- **Mobile App**: Running on your device/emulator

### 🚀 Deployment

#### Vercel Deployment (Recommended)

1. **Fork this repository**
2. **Connect to Vercel**:

   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click "New Project"
   - Import your forked repository
   - Set the **Root Directory** to `server`
   - Deploy!

3. **Configure Environment Variables** (optional):
   ```bash
   LOG_LEVEL=info
   CORS_ORIGIN=true
   RATE_LIMIT_GENERAL_MAX=100
   ```

#### Manual Deployment

```bash
# Build the server
cd server
npm run build

# Deploy to your preferred platform
# The built files are in the 'dist' directory
```

#### Mobile App Distribution

```bash
# Build for Android
cd mobile
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## API Endpoints

### Clean Link

```bash
POST /api/clean
Content-Type: application/json

{
  "url": "https://example.com?utm_source=google&utm_campaign=test",
  "strategyId": "optional-strategy-id"
}
```

### Preview Link

```bash
POST /api/preview
Content-Type: application/json

{
  "url": "https://example.com?utm_source=google",
  "strategyId": "optional-strategy-id"
}
```

### Strategy Management

```bash
GET /api/strategies          # List all strategies
GET /api/strategies/:id      # Get specific strategy
POST /api/strategies         # Create new strategy
PUT /api/strategies/:id      # Update strategy
DELETE /api/strategies/:id   # Delete strategy
```

## Strategy Configuration

Strategies are defined using a flexible JSON schema:

```json
{
  "id": "youtube",
  "name": "YouTube",
  "version": "1.0.0",
  "enabled": true,
  "priority": 100,
  "matchers": [
    {
      "type": "exact",
      "pattern": "youtube.com"
    }
  ],
  "paramPolicies": [
    {
      "name": "v",
      "action": "allow",
      "reason": "Video ID - essential for content"
    },
    {
      "name": "utm_*",
      "action": "deny",
      "reason": "UTM tracking parameters"
    }
  ],
  "pathRules": [
    {
      "pattern": "^/watch\\?.*",
      "replacement": "/watch",
      "type": "regex"
    }
  ],
  "redirectPolicy": {
    "follow": true,
    "maxDepth": 2,
    "timeoutMs": 3000,
    "allowedSchemes": ["http", "https"]
  },
  "canonicalBuilders": [
    {
      "type": "domain",
      "template": "www.youtube.com",
      "required": true
    }
  ]
}
```

## Supported Platforms

### Pre-built Strategies

- **Instagram** - Removes tracking while preserving content IDs
- **YouTube** - Keeps video/playlist IDs and playback controls
- **Twitter/X** - Preserves tweet identifiers
- **TikTok** - Maintains video identifiers
- **Facebook** - Keeps content IDs
- **LinkedIn** - Preserves post/article identifiers
- **Reddit** - Maintains subreddit and post IDs
- **Pinterest** - Keeps pin and board identifiers
- **GitHub** - Preserves repository and content paths
- **Medium** - Maintains article identifiers

### Generic Strategy

For unknown domains, applies safe generic cleaning:

- Follows redirects (with limits)
- Removes common tracking parameters
- Preserves content-essential parameters
- Normalizes URL structure

## Development

### Server Development

```bash
cd server
npm run dev          # Start with hot reload
npm run build        # Build for production
npm test            # Run tests
npm run lint        # Lint code
```

### Mobile Development

```bash
cd mobile
flutter run         # Run on connected device
flutter test        # Run tests
flutter analyze     # Analyze code
```

### Monorepo Commands

```bash
npm run dev         # Start both server and mobile
npm run build       # Build both projects
npm test           # Test both projects
npm run lint       # Lint both projects
```

## Architecture

### Strategy Engine

The core cleaning logic is implemented as a modular strategy engine:

1. **URL Parsing** - Parse and validate input URL
2. **Strategy Matching** - Find applicable strategy by domain
3. **Redirect Resolution** - Follow redirects safely
4. **Parameter Processing** - Apply allow/deny rules
5. **Path Rewriting** - Apply path transformation rules
6. **Canonicalization** - Apply domain/path canonicalization
7. **Alternative Generation** - Create alternative cleaned links

### Mobile App Architecture

- **Provider Pattern** - State management with Provider
- **SQLite** - Local history storage
- **Shared Preferences** - Settings persistence
- **Share Intent** - OS integration for URL sharing

### API Architecture

- **Fastify** - High-performance web framework
- **TypeScript** - Type-safe development
- **Modular Routes** - Clean separation of concerns
- **Error Handling** - Comprehensive error responses

## Performance

- **P95 < 400ms** for non-redirect links
- **Redirect limits** - Maximum 10 redirects, 5s timeout
- **Caching** - Strategy caching for known patterns
- **Efficient parsing** - Optimized URL processing

## Safety Features

- **SSRF Protection** - Restricted redirect schemes
- **Input Validation** - Comprehensive URL validation
- **Error Handling** - Graceful fallbacks
- **Rate Limiting** - Built-in request limiting
- **Sanitization** - Safe parameter processing

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run server tests only
cd server && npm test

# Run mobile tests only
cd mobile && flutter test

# Run with coverage
cd server && npm run test:coverage
```

### Test Coverage

- **Server**: Jest with TypeScript
- **Mobile**: Flutter test framework
- **Integration**: API endpoint testing
- **E2E**: Full workflow testing

## 📱 Mobile App

### Features

- **Share Integration**: Clean links directly from other apps
- **Offline Mode**: Process links locally for privacy
- **History Management**: Save and organize cleaned links
- **Custom Strategies**: Create your own cleaning rules
- **Dark/Light Theme**: Automatic theme switching

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

## 🔧 API Documentation

### Base URL

- **Production**: `https://traceoff.vercel.app/api`
- **Development**: `http://localhost:3000/api`

### Authentication

Currently, the API is public. Rate limiting is applied per IP address.

### Rate Limits

- **General API**: 100 requests per minute
- **Clean Endpoint**: 20 requests per minute
- **Health Check**: 1000 requests per minute

## 🏗️ Architecture

### System Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Mobile App    │    │   Web Admin     │    │   External      │
│   (Flutter)     │    │   (HTML/JS)     │    │   Apps          │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │      TraceOff API         │
                    │    (Node.js/Fastify)      │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │    Strategy Engine        │
                    │  (URL Processing Core)    │
                    └───────────────────────────┘
```

### Technology Stack

- **Frontend**: Flutter (Mobile), HTML/CSS/JS (Admin)
- **Backend**: Node.js, TypeScript, Fastify
- **Database**: SQLite (Mobile), In-memory (Server)
- **Deployment**: Vercel (Server), APK/App Store (Mobile)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes
4. **Add** tests for new functionality
5. **Run** the test suite (`npm test`)
6. **Commit** your changes (`git commit -m 'Add amazing feature'`)
7. **Push** to the branch (`git push origin feature/amazing-feature`)
8. **Open** a Pull Request

### Code Style

- **TypeScript**: ESLint + Prettier
- **Flutter**: Dart analysis + `flutter analyze`
- **Commits**: Conventional Commits format

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help

- 📖 **Documentation**: Check this README and inline code comments
- 🐛 **Bug Reports**: [Create an issue](https://github.com/aimuhire/traceoff/issues)
- 💡 **Feature Requests**: [Create an issue](https://github.com/aimuhire/traceoff/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/aimuhire/traceoff/discussions)

### Community

- 🌟 **Star** this repository if you find it helpful
- 🍴 **Fork** it to contribute
- 📢 **Share** it with others

---

<div align="center">

**Made with ❤️ by the TraceOff Team**

[⬆ Back to Top](#traceoff)

</div>
