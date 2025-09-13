#!/bin/bash

# Link Cleaner Development Script
# This script helps set up and run the development environment

set -e

echo "🚀 Link Cleaner Development Setup"
echo "================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

if ! command_exists npm; then
    echo "❌ npm is not installed. Please install npm."
    exit 1
fi

if ! command_exists flutter; then
    echo "❌ Flutter is not installed. Please install Flutter 3.10+ from https://flutter.dev/"
    exit 1
fi

echo "✅ All prerequisites found"

# Install dependencies
echo "📦 Installing dependencies..."

echo "Installing root dependencies..."
npm install

echo "Installing server dependencies..."
cd server
npm install
cd ..

echo "Installing mobile dependencies..."
cd mobile
flutter pub get
cd ..

echo "✅ Dependencies installed"

# Build server
echo "🔨 Building server..."
cd server
npm run build
cd ..

echo "✅ Server built"

# Run tests
echo "🧪 Running tests..."

echo "Running server tests..."
cd server
npm test
cd ..

echo "Running mobile tests..."
cd mobile
flutter test
cd ..

echo "✅ All tests passed"

# Start development servers
echo "🚀 Starting development servers..."
echo ""
echo "Starting server on http://localhost:3000"
echo "Admin UI available at http://localhost:3000/admin"
echo "Starting Flutter app..."
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Start server in background
cd server
npm run dev &
SERVER_PID=$!
cd ..

# Start Flutter app
cd mobile
flutter run &
FLUTTER_PID=$!
cd ..

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping servers..."
    kill $SERVER_PID 2>/dev/null || true
    kill $FLUTTER_PID 2>/dev/null || true
    echo "✅ Servers stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Wait for processes
wait
