# Contributing to TraceOff

Thank you for your interest in contributing to TraceOff! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+ and npm
- **Flutter** 3.10+
- **Git** for version control
- **Code editor** (VS Code recommended)

### Development Setup

1. **Fork and Clone**

   ```bash
   git clone https://github.com/aimuhire/traceoff.git
   cd traceoff
   ```

2. **Install Dependencies**

   ```bash
   # Root dependencies
   npm install

   # Server dependencies
   cd server && npm install

   # Mobile dependencies
   cd ../mobile && flutter pub get
   ```

3. **Start Development**

   ```bash
   # Start both server and mobile
   npm run dev

   # Or start individually
   npm run dev:server  # Server only
   npm run dev:mobile  # Mobile only
   ```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run specific tests
npm run test:server    # Server tests only
npm run test:mobile    # Mobile tests only
npm run test:api       # API integration tests
```

### Test Coverage

- **Server**: Jest with TypeScript
- **Mobile**: Flutter test framework
- **Integration**: API endpoint testing

### Writing Tests

- **Server**: Add tests in `server/src/__tests__/`
- **Mobile**: Add tests in `mobile/test/`
- **Integration**: Add API tests in the test workflow

## 📝 Code Style

### TypeScript/JavaScript

- Use **ESLint** and **Prettier** (configured)
- Follow **conventional commits** format
- Use **TypeScript** for type safety
- Write **JSDoc** comments for public APIs

### Flutter/Dart

- Use **flutter analyze** for linting
- Follow **Dart style guide**
- Use **Provider** for state management
- Write **widget tests** for UI components

### Git Workflow

1. **Create a branch**

   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make changes and commit**

   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

3. **Push and create PR**
   ```bash
   git push origin feature/amazing-feature
   ```

## 🐛 Bug Reports

When reporting bugs, please include:

- **Description** of the issue
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Environment** (OS, Node.js version, Flutter version)
- **Screenshots** (if applicable)

## 💡 Feature Requests

When suggesting features, please include:

- **Use case** and motivation
- **Detailed description**
- **Proposed implementation** (if you have ideas)
- **Alternatives** considered

## 🔧 Development Guidelines

### Server Development

- **API Design**: Follow RESTful principles
- **Error Handling**: Use proper HTTP status codes
- **Logging**: Use structured logging
- **Security**: Validate all inputs
- **Performance**: Optimize for speed

### Mobile Development

- **UI/UX**: Follow Material Design principles
- **State Management**: Use Provider pattern
- **Offline Support**: Handle network failures gracefully
- **Accessibility**: Support screen readers
- **Performance**: Optimize for smooth scrolling

### Code Review Process

1. **Self-review** your code before submitting
2. **Write tests** for new functionality
3. **Update documentation** if needed
4. **Ensure CI passes** before requesting review
5. **Respond to feedback** promptly

## 📚 Documentation

### README Updates

- Update **installation** instructions if needed
- Add **new features** to the features list
- Update **API documentation** for new endpoints
- Add **screenshots** for UI changes

### Code Documentation

- **JSDoc** comments for TypeScript functions
- **DartDoc** comments for Dart classes and methods
- **Inline comments** for complex logic
- **README files** for complex modules

## 🚀 Deployment

### Server Deployment

- **Vercel**: Automatic deployment on main branch
- **Environment Variables**: Configure in Vercel dashboard
- **Build Process**: Handled by GitHub Actions

### Mobile Deployment

- **Android**: Build APK/AAB for distribution
- **iOS**: Build for App Store (requires macOS)
- **Web**: Build for web deployment

## 🤝 Community Guidelines

### Be Respectful

- Use **welcoming language**
- Be **respectful** of differing viewpoints
- **Accept constructive criticism**
- Focus on **what's best** for the community

### Be Collaborative

- **Help others** when you can
- **Share knowledge** and experience
- **Ask questions** when you need help
- **Mentor newcomers**

## 📄 License

By contributing to TraceOff, you agree that your contributions will be licensed under the MIT License.

## 🆘 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Discord**: Join our community (if available)
- **Email**: Contact maintainers directly

## 🎉 Recognition

Contributors will be recognized in:

- **README.md** contributors section
- **Release notes** for significant contributions
- **GitHub** contributor statistics
- **Community** appreciation

---

Thank you for contributing to TraceOff! 🚀
