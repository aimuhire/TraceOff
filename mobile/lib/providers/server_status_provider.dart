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
      } else if (healthData['status'] == 'error') {
        _status = ServerStatus.error;
        _errorMessage = healthData['error'];
      } else {
        _status = ServerStatus.offline;
        _errorMessage = healthData['error'];
      }
    } catch (e) {
      _status = ServerStatus.error;
      _errorMessage = e.toString();
      _lastChecked = DateTime.now();
    }

    notifyListeners();
  }

  void reset() {
    _status = ServerStatus.unknown;
    _errorMessage = null;
    _lastChecked = null;
    _serverTimestamp = null;
    _serverStatus = null;
    _responseTime = null;
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
