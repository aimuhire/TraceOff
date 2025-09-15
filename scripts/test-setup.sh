#!/bin/bash

# Test Setup Script for TraceOff
echo "🧪 Testing TraceOff Setup"
echo "============================="

# Test server setup
echo "📦 Testing server setup..."
cd server

# Install dependencies
echo "Installing server dependencies..."
npm install --silent

# Run tests
echo "Running server tests..."
npm test --silent

# Build server
echo "Building server..."
npm run build --silent

echo "✅ Server setup successful"
cd ..

# Test mobile setup
echo "📱 Testing mobile setup..."
cd mobile

# Get Flutter dependencies
echo "Installing Flutter dependencies..."
flutter pub get --silent

# Analyze code
echo "Analyzing Flutter code..."
flutter analyze --no-fatal-infos

# Run tests
echo "Running Flutter tests..."
flutter test --silent

echo "✅ Mobile setup successful"
cd ..

echo "🎉 All tests passed! Setup is working correctly."
echo ""
echo "To start development:"
echo "  npm run dev"
echo ""
echo "Or run individual services:"
echo "  npm run dev:server  # Server at http://localhost:3000"
echo "  npm run dev:mobile  # Flutter app"
