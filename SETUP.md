# TraceOff Setup Guide

This guide will help you set up TraceOff for development and deployment.

## 🚀 Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/traceoff.git
cd traceoff
```

### 2. Install Dependencies

```bash
# Install root dependencies
npm install

# Install server dependencies
cd server && npm install

# Install mobile dependencies
cd ../mobile && flutter pub get
```

### 3. Start Development

```bash
# Start both server and mobile
npm run dev

# Or start individually
npm run dev:server  # Server only
npm run dev:mobile  # Mobile only
```

## 🔧 Development Environment

### Prerequisites

- **Node.js** 18+ and npm
- **Flutter** 3.10+
- **Git** for version control
- **VS Code** (recommended)

### VS Code Extensions

Install these recommended extensions:

- **Dart** (for Flutter development)
- **TypeScript** (for server development)
- **ESLint** (for code linting)
- **Prettier** (for code formatting)
- **GitLens** (for Git integration)

### Environment Configuration

Create a `.env` file in the server directory:

```bash
# Copy the example file
cp server/env.example server/.env

# Edit the configuration
nano server/.env
```

## 🧪 Testing

### Run All Tests

```bash
npm test
```

### Run Specific Tests

```bash
# Server tests only
npm run test:server

# Mobile tests only
npm run test:mobile

# API integration tests
npm run test:api
```

### Test Coverage

```bash
# Server coverage
cd server && npm run test:coverage

# Mobile coverage
cd mobile && flutter test --coverage
```

## 🚀 Deployment

### Vercel (Recommended)

1. **Fork this repository**
2. **Connect to Vercel**:

   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click "New Project"
   - Import your forked repository
   - Set **Root Directory** to `server`
   - Deploy!

3. **Configure Environment Variables** in Vercel dashboard

### Manual Deployment

```bash
# Build the server
cd server
npm run build

# Deploy to Vercel
vercel --prod
```

## 📱 Mobile App

### Android

```bash
cd mobile
flutter build apk --release
```

### iOS (macOS required)

```bash
cd mobile
flutter build ios --release
```

### Web

```bash
cd mobile
flutter build web --release
```

## 🔍 Troubleshooting

### Common Issues

1. **Flutter not found**

   ```bash
   # Install Flutter
   # Follow: https://flutter.dev/docs/get-started/install
   ```

2. **Node.js version issues**

   ```bash
   # Use Node Version Manager
   nvm install 18
   nvm use 18
   ```

3. **Dependencies not installing**

   ```bash
   # Clear caches
   npm cache clean --force
   flutter clean
   flutter pub get
   ```

4. **Build failures**
   ```bash
   # Check logs
   npm run build 2>&1 | tee build.log
   flutter build apk --verbose
   ```

### Getting Help

- **GitHub Issues**: [Create an issue](https://github.com/yourusername/traceoff/issues)
- **Documentation**: Check README.md and CONTRIBUTING.md
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/traceoff/discussions)

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Node.js Documentation](https://nodejs.org/docs)
- [Vercel Documentation](https://vercel.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

Happy coding! 🚀
