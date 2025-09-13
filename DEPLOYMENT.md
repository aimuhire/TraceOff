# Deployment Guide

This guide covers deploying TraceOff to various platforms.

## 🚀 Vercel Deployment (Recommended)

### Automatic Deployment

1. **Fork this repository**
2. **Connect to Vercel**:

   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click "New Project"
   - Import your forked repository
   - Set **Root Directory** to `server`
   - Deploy!

3. **Configure Environment Variables**:
   ```bash
   NODE_ENV=production
   LOG_LEVEL=info
   CORS_ORIGIN=true
   CORS_CREDENTIALS=true
   RATE_LIMIT_GENERAL_MAX=100
   RATE_LIMIT_CLEAN_MAX=20
   RATE_LIMIT_HEALTH_MAX=1000
   ```

### Manual Deployment

```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from server directory
cd server
vercel --prod
```

## 📱 Mobile App Deployment

### Android

#### APK Distribution

```bash
cd mobile
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Google Play Store

```bash
cd mobile
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS required)

```bash
cd mobile
flutter build ios --release

# Open Xcode and archive for App Store
open ios/Runner.xcworkspace
```

### Web Deployment

```bash
cd mobile
flutter build web --release

# Deploy the build/web directory to any static hosting
```

## 🔧 Environment Configuration

### Production Environment Variables

```bash
# Server Configuration
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Logging
LOG_LEVEL=info

# CORS
CORS_ORIGIN=true
CORS_CREDENTIALS=true

# Rate Limiting
RATE_LIMIT_GENERAL_MAX=100
RATE_LIMIT_GENERAL_WINDOW=1m
RATE_LIMIT_CLEAN_MAX=20
RATE_LIMIT_CLEAN_WINDOW=1m
RATE_LIMIT_HEALTH_MAX=1000
RATE_LIMIT_HEALTH_WINDOW=1m
RATE_LIMIT_ADMIN_MAX=50
RATE_LIMIT_ADMIN_WINDOW=1m

# Security
ENABLE_HTTPS=true
RATE_LIMIT_WHITELIST_IPS=127.0.0.1,::1

# Performance
EXTERNAL_API_TIMEOUT=10000
EXTERNAL_API_RETRY_ATTEMPTS=3
CACHE_TTL=3600
ENABLE_CACHE=true

# Monitoring
ENABLE_METRICS=true
ENABLE_SWAGGER=true
ENABLE_DEBUG_ROUTES=false
```

## 🐳 Docker Deployment

### Server Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ./dist/

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

### Build and Run

```bash
# Build server
cd server
npm run build

# Build Docker image
docker build -t traceoff-server .

# Run container
docker run -p 3000:3000 traceoff-server
```

## ☁️ Other Cloud Platforms

### Railway

1. Connect your GitHub repository
2. Set **Root Directory** to `server`
3. Configure environment variables
4. Deploy!

### Render

1. Create a new **Web Service**
2. Connect your GitHub repository
3. Set **Root Directory** to `server`
4. Configure environment variables
5. Deploy!

### Heroku

```bash
# Create Procfile
echo "web: node dist/index.js" > server/Procfile

# Deploy
cd server
git init
heroku create your-app-name
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

## 🔍 Monitoring and Logs

### Vercel

- **Logs**: Available in Vercel dashboard
- **Metrics**: Built-in performance monitoring
- **Alerts**: Configure in project settings

### Custom Monitoring

```bash
# Health check endpoint
curl https://your-app.vercel.app/health

# API status
curl https://your-app.vercel.app/api/strategies
```

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**

   - Check Node.js version (18+)
   - Verify all dependencies are installed
   - Check TypeScript compilation errors

2. **Runtime Errors**

   - Verify environment variables
   - Check logs for specific errors
   - Ensure all required services are running

3. **Performance Issues**
   - Monitor rate limiting
   - Check external API timeouts
   - Optimize database queries

### Debug Mode

```bash
# Enable debug logging
LOG_LEVEL=debug
ENABLE_DEBUG_ROUTES=true
```

## 📊 Performance Optimization

### Server Optimization

- **Caching**: Enable Redis for distributed caching
- **CDN**: Use Vercel's edge network
- **Compression**: Enable gzip compression
- **Rate Limiting**: Configure appropriate limits

### Mobile Optimization

- **Code Splitting**: Use lazy loading
- **Image Optimization**: Compress assets
- **Bundle Size**: Minimize dependencies
- **Offline Support**: Cache critical data

## 🔒 Security Considerations

### API Security

- **Rate Limiting**: Prevent abuse
- **CORS**: Configure appropriate origins
- **Input Validation**: Sanitize all inputs
- **HTTPS**: Always use secure connections

### Mobile Security

- **Certificate Pinning**: For API calls
- **Data Encryption**: Sensitive data at rest
- **Secure Storage**: Use platform keychain
- **Code Obfuscation**: Protect intellectual property

## 📈 Scaling

### Horizontal Scaling

- **Load Balancers**: Distribute traffic
- **Multiple Instances**: Run multiple servers
- **Database Clustering**: For persistent storage
- **CDN**: Global content distribution

### Vertical Scaling

- **Memory**: Increase server memory
- **CPU**: Upgrade processing power
- **Storage**: Add more disk space
- **Network**: Increase bandwidth

---

For more help, check the [Contributing Guide](CONTRIBUTING.md) or [open an issue](https://github.com/yourusername/traceoff/issues).
