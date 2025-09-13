import 'package:flutter/material.dart';
import 'package:traceoff_mobile/models/history_item.dart';
import 'package:traceoff_mobile/services/database_service.dart';

class HistoryProvider with ChangeNotifier {
  List<HistoryItem> _historyItems = [];
  List<HistoryItem> _favoriteItems = [];
  bool _isLoading = false;

  List<HistoryItem> get historyItems => _historyItems;
  List<HistoryItem> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _historyItems = await DatabaseService.instance.getAllHistoryItems();
      _favoriteItems = await DatabaseService.instance.getFavoriteHistoryItems();
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(HistoryItem item) async {
    try {
      await DatabaseService.instance.insertHistoryItem(item);
      await loadHistory(); // Reload to get updated list
    } catch (e) {
      print('Error adding to history: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await DatabaseService.instance.toggleFavorite(id);
      await loadHistory(); // Reload to get updated list
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      await DatabaseService.instance.deleteHistoryItem(id);
      await loadHistory(); // Reload to get updated list
    } catch (e) {
      print('Error deleting history item: $e');
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await DatabaseService.instance.clearAllHistory();
      await loadHistory(); // Reload to get updated list
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  Future<List<HistoryItem>> searchHistory(String query) async {
    try {
      return await DatabaseService.instance.searchHistory(query);
    } catch (e) {
      print('Error searching history: $e');
      return [];
    }
  }

  HistoryItem? getHistoryItem(String id) {
    try {
      return _historyItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
