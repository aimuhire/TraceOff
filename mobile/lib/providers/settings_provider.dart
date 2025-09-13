import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traceoff_mobile/config/environment.dart';
import 'package:traceoff_mobile/models/cleaning_strategy.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider(this._prefs);

  final SharedPreferences _prefs;

  // Settings keys
  static const String _autoCopyKey = 'auto_copy_primary';
  static const String _showConfirmationKey = 'show_confirmation';
  static const String _defaultStrategyKey = 'default_strategy';
  static const String _themeModeKey = 'theme_mode';
  static const String _serverUrlKey = 'server_url';
  static const String _showPreviewsKey = 'show_clean_link_previews';
  static const String _autoSubmitClipboardKey = 'auto_submit_clipboard';
  static const String _autoShareOnSuccessKey = 'auto_share_on_success';
  static const String _offlineModeKey = 'offline_mode';
  static const String _strategiesKey = 'cleaning_strategies_v1';
  static const String _activeStrategyIdKey = 'active_strategy_id_v1';

  // Default values
  bool _autoCopyPrimary = true;
  bool _showConfirmation = true;
  bool _showCleanLinkPreviews = true;
  bool _autoSubmitClipboard = true;
  bool _autoShareOnSuccess = true;
  bool _offlineMode = false;
  String? _defaultStrategy;
  ThemeMode _themeMode = ThemeMode.system;
  String _serverUrl = EnvironmentConfig.baseUrl;
  List<CleaningStrategy> _strategies = const [];
  String? _activeStrategyId;

  // Getters
  bool get autoCopyPrimary => _autoCopyPrimary;
  bool get showConfirmation => _showConfirmation;
  bool get showCleanLinkPreviews => _showCleanLinkPreviews;
  bool get autoSubmitClipboard => _autoSubmitClipboard;
  bool get autoShareOnSuccess => _autoShareOnSuccess;
  bool get offlineMode => _offlineMode;
  String? get defaultStrategy => _defaultStrategy;
  ThemeMode get themeMode => _themeMode;
  String get serverUrl => _serverUrl;
  List<CleaningStrategy> get strategies => _strategies;
  String? get activeStrategyId => _activeStrategyId;
  CleaningStrategy? get activeStrategy {
    try {
      return _strategies.firstWhere((s) => s.id == _activeStrategyId);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    _autoCopyPrimary = _prefs.getBool(_autoCopyKey) ?? true;
    _showConfirmation = _prefs.getBool(_showConfirmationKey) ?? true;
    _showCleanLinkPreviews = _prefs.getBool(_showPreviewsKey) ?? true;
    _autoSubmitClipboard = _prefs.getBool(_autoSubmitClipboardKey) ?? true;
    _autoShareOnSuccess = _prefs.getBool(_autoShareOnSuccessKey) ?? true;
    _offlineMode = _prefs.getBool(_offlineModeKey) ?? false;
    _defaultStrategy = _prefs.getString(_defaultStrategyKey);
    _themeMode = ThemeMode.values[_prefs.getInt(_themeModeKey) ?? 0];
    _serverUrl = _prefs.getString(_serverUrlKey) ?? EnvironmentConfig.baseUrl;
    final strategiesRaw = _prefs.getString(_strategiesKey);
    if (strategiesRaw != null && strategiesRaw.isNotEmpty) {
      try {
        _strategies = CleaningStrategy.decodeList(strategiesRaw);
      } catch (_) {
        _strategies = const [];
      }
    }
    _activeStrategyId = _prefs.getString(_activeStrategyIdKey);
    notifyListeners();
  }

  Future<void> setAutoSubmitClipboard(bool value) async {
    _autoSubmitClipboard = value;
    await _prefs.setBool(_autoSubmitClipboardKey, value);
    notifyListeners();
  }

  Future<void> setAutoShareOnSuccess(bool value) async {
    _autoShareOnSuccess = value;
    await _prefs.setBool(_autoShareOnSuccessKey, value);
    notifyListeners();
  }

  Future<void> setOfflineMode(bool value) async {
    _offlineMode = value;
    await _prefs.setBool(_offlineModeKey, value);
    notifyListeners();
  }

  Future<void> setAutoCopyPrimary(bool value) async {
    _autoCopyPrimary = value;
    await _prefs.setBool(_autoCopyKey, value);
    notifyListeners();
  }

  Future<void> setShowConfirmation(bool value) async {
    _showConfirmation = value;
    await _prefs.setBool(_showConfirmationKey, value);
    notifyListeners();
  }

  Future<void> setShowCleanLinkPreviews(bool value) async {
    _showCleanLinkPreviews = value;
    await _prefs.setBool(_showPreviewsKey, value);
    notifyListeners();
  }

  Future<void> setDefaultStrategy(String? value) async {
    _defaultStrategy = value;
    if (value != null) {
      await _prefs.setString(_defaultStrategyKey, value);
    } else {
      await _prefs.remove(_defaultStrategyKey);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    await _prefs.setInt(_themeModeKey, value.index);
    notifyListeners();
  }

  Future<void> setServerUrl(String value) async {
    _serverUrl = value;
    await _prefs.setString(_serverUrlKey, value);
    notifyListeners();
  }

  Future<void> upsertStrategy(CleaningStrategy strategy) async {
    final idx = _strategies.indexWhere((s) => s.id == strategy.id);
    if (idx >= 0) {
      _strategies = List.of(_strategies)..[idx] = strategy;
    } else {
      _strategies = List.of(_strategies)..add(strategy);
    }
    await _prefs.setString(
        _strategiesKey, CleaningStrategy.encodeList(_strategies));
    notifyListeners();
  }

  Future<void> deleteStrategy(String id) async {
    _strategies = _strategies.where((s) => s.id != id).toList();
    if (_activeStrategyId == id) {
      _activeStrategyId = null;
      await _prefs.remove(_activeStrategyIdKey);
    }
    await _prefs.setString(
        _strategiesKey, CleaningStrategy.encodeList(_strategies));
    notifyListeners();
  }

  Future<void> setActiveStrategy(String? id) async {
    _activeStrategyId = id;
    if (id == null) {
      await _prefs.remove(_activeStrategyIdKey);
    } else {
      await _prefs.setString(_activeStrategyIdKey, id);
    }
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _prefs.clear();
    await init();
  }
}
