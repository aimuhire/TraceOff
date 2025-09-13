import 'dart:io';
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
          print('📱 Platform: ${Platform.operatingSystem}');
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

    if (env == 'production') {
      final prodUrl = dotenv.env['PROD_API_BASE_URL'] ??
          'https://your-production-server.com';
      if (enableDebugLogging) {
        print('🏭 Production URL: $prodUrl');
      }
      return prodUrl;
    }

    // Development environment
    if (Platform.isAndroid) {
      // Use 10.0.2.2 for Android emulator to access host machine
      final androidUrl =
          dotenv.env['ANDROID_API_BASE_URL'] ?? 'http://10.0.2.2:3000';
      if (enableDebugLogging) {
        print('🤖 Android URL: $androidUrl');
        print('📱 Platform: ${Platform.operatingSystem}');
      }
      return androidUrl;
    } else {
      // Use localhost for iOS simulator, web, desktop, etc.
      final devUrl = dotenv.env['DEV_API_BASE_URL'] ?? 'http://localhost:3000';
      if (enableDebugLogging) {
        print('🛠️  Development URL: $devUrl');
        print('📱 Platform: ${Platform.operatingSystem}');
      }
      return devUrl;
    }
  }

  static String get apiUrl => '$baseUrl/api';

  // Helper method to detect if running on emulator
  static bool get isEmulator {
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
      dotenv.env['DATABASE_NAME'] ?? 'link_cleaner.db';
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
      print('📱 Platform: ${Platform.operatingSystem}');
      print('🤖 Is Android Emulator: $isEmulator');
      print('⏱️  API Timeout: ${apiTimeoutSeconds}s');
      print('🔄 API Retry Attempts: $apiRetryAttempts');
      print('🐛 Debug Logging: $enableDebugLogging');
      print('💾 Database Name: $databaseName');
      print('💾 Database Version: $databaseVersion');
      print('🔧 === END CONFIGURATION ===');
    }
  }
}
