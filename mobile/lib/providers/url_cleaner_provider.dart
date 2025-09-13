import 'package:flutter/material.dart';
import 'package:traceoff_mobile/models/clean_result.dart';
import 'package:traceoff_mobile/services/api_service.dart';
import 'package:traceoff_mobile/services/offline_cleaner_service.dart';
import 'package:traceoff_mobile/services/database_service.dart';
import 'package:traceoff_mobile/models/history_item.dart';
import 'package:traceoff_mobile/services/custom_strategy_runner.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';

class UrlCleanerProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  CleanResult? _result;
  String _currentUrl = '';
  String? _pendingInputUrl;
  bool _isOfflineMode = false;
  SettingsProvider? _settings;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CleanResult? get result => _result;
  String get currentUrl => _currentUrl;
  String? get pendingInputUrl => _pendingInputUrl;
  bool get isOfflineMode => _isOfflineMode;

  void attachSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  void setPendingInputUrl(String url) {
    _pendingInputUrl = url;
    notifyListeners();
  }

  String? takePendingInputUrl() {
    final value = _pendingInputUrl;
    _pendingInputUrl = null;
    return value;
  }

  void setOfflineMode(bool isOffline) {
    _isOfflineMode = isOffline;
    notifyListeners();
  }

  Future<void> cleanUrl(String url) async {
    if (url.isEmpty) return;

    _isLoading = true;
    _error = null;
    _currentUrl = url;
    notifyListeners();

    try {
      CleanResult result;

      if (_isOfflineMode) {
        // Use custom active strategy if available, else fallback to offline cleaner
        final active = _settings?.activeStrategy;
        if (active != null) {
          // ignore: avoid_print
          print(
              '[UrlCleanerProvider] Using custom strategy: ${active.name} (${active.steps.length} steps)');
          result = await CustomStrategyRunner.run(url, active);
        } else {
          // ignore: avoid_print
          print('[UrlCleanerProvider] Using default offline cleaner');
          result = await OfflineCleanerService.cleanUrl(url);
        }
      } else {
        // Try online first, fallback to offline if API fails
        try {
          // ignore: avoid_print
          print('[UrlCleanerProvider] Using remote processing (API)');
          result = await ApiService.cleanUrl(url);
        } catch (e) {
          // API failed, signal that we need user confirmation for fallback
          // ignore: avoid_print
          print('[UrlCleanerProvider] Remote processing failed: $e');
          _error =
              'Remote processing failed. Would you like to clean this link locally?';
          _result = null;
          _isLoading = false;
          notifyListeners();
          return; // Exit early to show error and prompt user
        }
      }

      _result = result;
      _error = null;

      // Persist to local history (on-device only)
      try {
        final historyItem = HistoryItem(
          originalUrl: url,
          cleanedUrl: result.primary.url,
          domain: result.meta.domain,
          strategyId: result.meta.strategyId,
          confidence: result.primary.confidence,
          createdAt: DateTime.now(),
        );
        await DatabaseService.instance.insertHistoryItem(historyItem);
      } catch (e) {
        // Non-fatal: history persistence failure should not break UX
        // print or ignore in production
        // print('Failed to save history: $e');
      }
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> previewUrl(String url, {String? strategyId}) async {
    if (url.isEmpty) return;

    _isLoading = true;
    _error = null;
    _currentUrl = url;
    notifyListeners();

    try {
      final result = await ApiService.previewUrl(url, strategyId: strategyId);
      _result = result;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _result = null;
    _error = null;
    _currentUrl = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fallbackToOfflineMode(String url) async {
    if (url.isEmpty) return;

    // ignore: avoid_print
    print(
        '[UrlCleanerProvider] FALLBACK - Switching to offline mode for: $url');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      CleanResult result;

      // Use custom active strategy if available, else fallback to offline cleaner
      final active = _settings?.activeStrategy;
      if (active != null) {
        // ignore: avoid_print
        print(
            '[UrlCleanerProvider] FALLBACK - Using custom strategy: ${active.name}');
        result = await CustomStrategyRunner.run(url, active);
      } else {
        // ignore: avoid_print
        print('[UrlCleanerProvider] FALLBACK - Using default offline cleaner');
        result = await OfflineCleanerService.cleanUrl(url);
      }

      // Add a note that we fell back to offline mode
      result = CleanResult(
        primary: CleanedUrl(
          url: result.primary.url,
          confidence: result.primary.confidence,
          actions: [
            ...result.primary.actions,
            'Switched to local processing due to remote failure'
          ],
        ),
        alternatives: result.alternatives,
        meta: result.meta,
      );

      _result = result;
      _error = null;

      // Persist to local history (on-device only)
      try {
        final historyItem = HistoryItem(
          originalUrl: url,
          cleanedUrl: result.primary.url,
          domain: result.meta.domain,
          strategyId: result.meta.strategyId,
          confidence: result.primary.confidence,
          createdAt: DateTime.now(),
        );
        await DatabaseService.instance.insertHistoryItem(historyItem);
      } catch (e) {
        // Non-fatal: history persistence failure should not break UX
      }
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
