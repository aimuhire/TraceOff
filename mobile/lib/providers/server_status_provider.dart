import 'package:flutter/foundation.dart';
import 'package:traceoff_mobile/services/api_service.dart';

enum ServerStatus {
  unknown,
  checking,
  online,
  offline,
  error,
}

class ServerStatusProvider with ChangeNotifier {
  ServerStatus _status = ServerStatus.unknown;
  String? _errorMessage;
  DateTime? _lastChecked;
  String? _serverTimestamp;
  String? _serverStatus;
  int? _responseTime;
  int _consecutiveFailures = 0;
  DateTime? _lastFailureTime;

  ServerStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime? get lastChecked => _lastChecked;
  String? get serverTimestamp => _serverTimestamp;
  String? get serverStatus => _serverStatus;
  int? get responseTime => _responseTime;

  bool get isOnline => _status == ServerStatus.online;
  bool get isOffline => _status == ServerStatus.offline;
  bool get isChecking => _status == ServerStatus.checking;
  bool get hasError => _status == ServerStatus.error;

  String get statusText {
    switch (_status) {
      case ServerStatus.unknown:
        return 'Unknown';
      case ServerStatus.checking:
        return 'Checking...';
      case ServerStatus.online:
        return 'Online';
      case ServerStatus.offline:
        return 'Offline';
      case ServerStatus.error:
        return 'Error';
    }
  }

  String get statusIcon {
    switch (_status) {
      case ServerStatus.unknown:
        return 'cloud_question';
      case ServerStatus.checking:
        return 'cloud_sync';
      case ServerStatus.online:
        return 'cloud_done';
      case ServerStatus.offline:
        return 'cloud_off';
      case ServerStatus.error:
        return 'cloud_off';
    }
  }

  Future<void> checkServerStatus() async {
    // Check if we should skip this health check due to exponential backoff
    if (_shouldSkipHealthCheck()) {
      return;
    }

    _status = ServerStatus.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      final healthData = await ApiService.checkServerHealth();

      _lastChecked = DateTime.now();

      if (healthData['status'] == 'online') {
        _status = ServerStatus.online;
        _serverTimestamp = healthData['timestamp'];
        _serverStatus = healthData['serverStatus'];
        _responseTime = healthData['responseTime'];
        _errorMessage = null;
        // Reset failure count on success
        _consecutiveFailures = 0;
        _lastFailureTime = null;
      } else if (healthData['status'] == 'error') {
        _status = ServerStatus.error;
        _errorMessage = healthData['error'];
        _recordFailure();
      } else {
        _status = ServerStatus.offline;
        _errorMessage = healthData['error'];
        _recordFailure();
      }
    } catch (e) {
      _status = ServerStatus.error;
      _errorMessage = e.toString();
      _lastChecked = DateTime.now();
      _recordFailure();
    }

    notifyListeners();
  }

  bool _shouldSkipHealthCheck() {
    if (_consecutiveFailures == 0) return false;
    
    final now = DateTime.now();
    if (_lastFailureTime == null) return false;
    
    // Calculate exponential backoff delay: 2^failures seconds, max 300 seconds (5 minutes)
    final delaySeconds = (1 << _consecutiveFailures).clamp(1, 300);
    final timeSinceLastFailure = now.difference(_lastFailureTime!).inSeconds;
    
    return timeSinceLastFailure < delaySeconds;
  }

  void _recordFailure() {
    _consecutiveFailures++;
    _lastFailureTime = DateTime.now();
  }

  void reset() {
    _status = ServerStatus.unknown;
    _errorMessage = null;
    _lastChecked = null;
    _serverTimestamp = null;
    _serverStatus = null;
    _responseTime = null;
    _consecutiveFailures = 0;
    _lastFailureTime = null;
    notifyListeners();
  }

  String get lastCheckedText {
    if (_lastChecked == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastChecked!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String get responseTimeText {
    if (_responseTime == null) return '';
    return '${_responseTime}ms';
  }
}
