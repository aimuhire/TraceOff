import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traceoff_mobile/models/clean_result.dart';
import 'package:traceoff_mobile/config/environment.dart';

class ApiService {
  static String get baseUrl => EnvironmentConfig.effectiveApiUrl;

  static Future<void> initialize() async {
    await EnvironmentConfig.initialize();

    if (EnvironmentConfig.enableDebugLogging) {
      print('🚀 API Service initialized');
      EnvironmentConfig.printConfiguration();
    }
  }

  static Future<CleanResult> cleanUrl(String url, {String? strategyId}) async {
    final endpoint = '$baseUrl/clean';
    final requestBody = {
      'url': url,
      if (strategyId != null) 'strategyId': strategyId,
    };

    if (EnvironmentConfig.enableDebugLogging) {
      print('🧹 Cleaning URL: $url');
      print('🔗 Endpoint: $endpoint');
      print('📦 Request body: ${jsonEncode(requestBody)}');
      print('⏱️  Timeout: ${EnvironmentConfig.apiTimeoutSeconds}s');
    }

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: EnvironmentConfig.apiTimeoutSeconds));

      if (EnvironmentConfig.enableDebugLogging) {
        print('📡 Response status: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return CleanResult.fromJson(data['data']);
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvironmentConfig.enableDebugLogging) {
        print('❌ Error cleaning URL: $e');
        print('🔗 Failed endpoint: $endpoint');
        print('📦 Request body: ${jsonEncode(requestBody)}');
      }
      throw Exception('Failed to clean URL: $e');
    }
  }

  static Future<CleanResult> previewUrl(
    String url, {
    String? strategyId,
  }) async {
    final endpoint = '$baseUrl/preview';
    final requestBody = {
      'url': url,
      if (strategyId != null) 'strategyId': strategyId,
    };

    if (EnvironmentConfig.enableDebugLogging) {
      print('👁️  Previewing URL: $url');
      print('🔗 Endpoint: $endpoint');
      print('📦 Request body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: EnvironmentConfig.apiTimeoutSeconds));

      if (EnvironmentConfig.enableDebugLogging) {
        print('📡 Response status: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return CleanResult.fromJson(data['data']);
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvironmentConfig.enableDebugLogging) {
        print('❌ Error previewing URL: $e');
        print('🔗 Failed endpoint: $endpoint');
        print('📦 Request body: ${jsonEncode(requestBody)}');
      }
      throw Exception('Failed to preview URL: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStrategies() async {
    final endpoint = '$baseUrl/strategies';

    if (EnvironmentConfig.enableDebugLogging) {
      print('📋 Getting strategies');
      print('🔗 Endpoint: $endpoint');
    }

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: EnvironmentConfig.apiTimeoutSeconds));

      if (EnvironmentConfig.enableDebugLogging) {
        print('📡 Response status: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (EnvironmentConfig.enableDebugLogging) {
        print('❌ Error getting strategies: $e');
        print('🔗 Failed endpoint: $endpoint');
      }
      throw Exception('Failed to get strategies: $e');
    }
  }

  static Future<Map<String, dynamic>> checkServerHealth() async {
    // Health endpoint is now under /api prefix
    final endpoint = '$baseUrl/health';

    if (EnvironmentConfig.enableDebugLogging) {
      print('🏥 Checking server health');
      print('🔗 Endpoint: $endpoint');
    }

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: EnvironmentConfig.apiTimeoutSeconds));

      if (EnvironmentConfig.enableDebugLogging) {
        print('📡 Health check response status: ${response.statusCode}');
        print('📄 Health check response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'online',
          'timestamp': data['timestamp'],
          'serverStatus': data['status'],
          'responseTime': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        return {
          'status': 'error',
          'error': 'HTTP ${response.statusCode}',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      if (EnvironmentConfig.enableDebugLogging) {
        print('❌ Health check failed: $e');
        print('🔗 Failed endpoint: $endpoint');
      }
      return {
        'status': 'offline',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
