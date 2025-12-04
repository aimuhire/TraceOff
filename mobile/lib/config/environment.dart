import 'package:flutter/foundation.dart' show kIsWeb;
// Only use dart:io on non-web platforms
// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static bool _initialized = false;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Future<void> initialize() async {
    if (!_initialized) {
      try {
        await dotenv.load(fileName: '.env');
        _initialized = true;

        if (enableDebugLogging) {
          print('🔧 Environment initialized successfully');
          print('📁 Environment file loaded: .env');
          print(
              '🌍 Environment: ${dotenv.env['ENVIRONMENT'] ?? 'development'}');
          print('🔗 Base URL: $baseUrl');
          print('🔗 API URL: $apiUrl');
          print('📱 Platform: $_platformName');
          print('🤖 Is Android Emulator: $isEmulator');
        }
      } catch (e) {
        print('❌ Failed to load .env file: $e');
        print('⚠️  Using default configuration');
        _initialized = true;
      }
    }
  }

  static String get baseUrl {
    final env = dotenv.env['ENVIRONMENT'] ?? 'development';

    if (enableDebugLogging) {
      print('🔍 Getting base URL for environment: $env');
    }

    // If a generic API_BASE_URL is provided, prefer it across platforms
    final explicit = dotenv.env['API_BASE_URL'];
    if (explicit != null && explicit.isNotEmpty) {
      if (enableDebugLogging) {
        print('🔗 Using explicit API_BASE_URL: $explicit');
      }
      return explicit;
    }

    // Web: never use dart:io Platform. Prefer explicit WEB_API_BASE_URL, then PROD_API_BASE_URL, or fall back to current origin.
    if (kIsWeb) {
      final webUrl = dotenv.env['WEB_API_BASE_URL'] ??
          dotenv.env['PROD_API_BASE_URL'] ??
          Uri.base.origin;
      if (enableDebugLogging) {
        print('🌐 Web URL: $webUrl');
      }
      return webUrl;
    }

    if (env == 'production') {
      final prodUrl = dotenv.env['PROD_API_BASE_URL'] ??
          'https://your-production-server.com';
      if (enableDebugLogging) {
        print('🏭 Production URL: $prodUrl');
      }
      return prodUrl;
    }

    // Development environment
    if (!kIsWeb && Platform.isAndroid) {
      // Use 10.0.2.2 for Android emulator to access host machine
      final androidUrl =
          dotenv.env['ANDROID_API_BASE_URL'] ?? 'http://10.0.2.2:3000';
      if (enableDebugLogging) {
        print('🤖 Android URL: $androidUrl');
        print('📱 Platform: $_platformName');
      }
      return androidUrl;
    } else {
      // Use localhost for iOS simulator, web, desktop, etc.
      final devUrl = dotenv.env['DEV_API_BASE_URL'] ?? 'http://localhost:3000';
      if (enableDebugLogging) {
        print('🛠️  Development URL: $devUrl');
        print('📱 Platform: $_platformName');
      }
      return devUrl;
    }
  }

  static String get apiUrl => '$baseUrl/api';

  // Helper method to detect if running on emulator
  static bool get isEmulator {
    if (kIsWeb) return false;
    if (!Platform.isAndroid) return false;
    // Android emulator detection - can be overridden via environment variable
    return dotenv.env['IS_ANDROID_EMULATOR']?.toLowerCase() == 'true';
  }

  // Method to override for testing or specific scenarios
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String? _customBaseUrl;

  static String get effectiveBaseUrl => _customBaseUrl ?? baseUrl;
  static String get effectiveApiUrl => '$effectiveBaseUrl/api';

  // Additional configuration getters
  static int get apiTimeoutSeconds =>
      int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;
  static int get apiRetryAttempts =>
      int.tryParse(dotenv.env['API_RETRY_ATTEMPTS'] ?? '3') ?? 3;
  static bool get enableDebugLogging =>
      dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase() == 'true';
  static String get databaseName =>
      dotenv.env['DATABASE_NAME'] ?? 'traceoff.db';
  static int get databaseVersion =>
      int.tryParse(dotenv.env['DATABASE_VERSION'] ?? '1') ?? 1;

  // Debug method to print all configuration
  static void printConfiguration() {
    if (enableDebugLogging) {
      print('🔧 === ENVIRONMENT CONFIGURATION ===');
      print('🌍 Environment: ${dotenv.env['ENVIRONMENT'] ?? 'development'}');
      print('🔗 Base URL: $baseUrl');
      print('🔗 API URL: $apiUrl');
      print('🔗 Effective Base URL: $effectiveBaseUrl');
      print('🔗 Effective API URL: $effectiveApiUrl');
      print('📱 Platform: $_platformName');
      print('🤖 Is Android Emulator: $isEmulator');
      print('⏱️  API Timeout: ${apiTimeoutSeconds}s');
      print('🔄 API Retry Attempts: $apiRetryAttempts');
      print('🐛 Debug Logging: $enableDebugLogging');
      print('💾 Database Name: $databaseName');
      print('💾 Database Version: $databaseVersion');
      print('🔧 === END CONFIGURATION ===');
    }
  }

  static String get _platformName => kIsWeb ? 'web' : Platform.operatingSystem;
}
