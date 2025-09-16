import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:traceoff_mobile/models/history_item.dart';

class DatabaseService {
  const DatabaseService._init();

  static const DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static const String _prefsHistoryKey = 'history_items_v1';
  static const String _dbFileName = 'traceoff.db';

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database not supported on web');
    }
    if (_database != null) return _database!;
    _database = await _initDB(_dbFileName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // ignore: avoid_print
        print('[DB] onUpgrade old=$oldVersion new=$newVersion');
        if (oldVersion < 2) {
          // Add optional metadata columns introduced in v2
          try {
            await db.execute('ALTER TABLE history ADD COLUMN title TEXT');
          } catch (_) {
            // Column may already exist
          }
          try {
            await db
                .execute('ALTER TABLE history ADD COLUMN thumbnailUrl TEXT');
          } catch (_) {
            // Column may already exist
          }
          // ignore: avoid_print
          print('[DB] Migration to v2 complete');
        }
        if (oldVersion < 3) {
          // Ensure isFavorite column exists for older databases
          try {
            await db.execute(
                'ALTER TABLE history ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');
          } catch (_) {
            // Column may already exist; ignore
          }
          // ignore: avoid_print
          print('[DB] Migration to v3 complete (added isFavorite)');
        }
      },
    );
  }

  /// Destructively reset all stored history.
  ///
  /// - On web: clears SharedPreferences key used for history
  /// - On mobile: closes and deletes the SQLite database file, then re-creates it
  Future<void> resetDatabase() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsHistoryKey);
      // ignore: avoid_print
      print('[DB] Web history cleared (SharedPreferences)');
      return;
    }

    try {
      if (_database != null) {
        await _database!.close();
      }
    } catch (_) {}
    _database = null;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbFileName);
    // ignore: avoid_print
    print('[DB] Deleting SQLite database at $path');
    await deleteDatabase(path);
    // Recreate to ensure fresh schema
    await _initDB(_dbFileName);
    // ignore: avoid_print
    print('[DB] Database reset complete');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE history (
        id $idType,
        originalUrl $textType,
        cleanedUrl $textType,
        domain $textType,
        strategyId $textType,
        confidence $realType,
        createdAt $textType,
        isFavorite $boolType,
        title TEXT,
        thumbnailUrl TEXT
      )
    ''');
  }

  Future<void> init() async {
    if (kIsWeb) {
      // ignore: avoid_print
      print('[DB] Web platform detected - skipping SQLite init');
      return;
    }
    await database;
    // Logging: database initialized
    // ignore: avoid_print
    print('[DB] Initialized history database');
  }

  Future<String> insertHistoryItem(HistoryItem item) async {
    if (kIsWeb) {
      // Save to SharedPreferences as a JSON array
      final list = await _prefsLoadAll();
      final updated = [item, ...list];
      await _prefsSaveAll(updated);
      return item.id;
    }
    final db = await database;
    // Logging: inserting history item
    // ignore: avoid_print
    print(
        '[DB] Inserting history item for domain=${item.domain} cleanedUrl=${item.cleanedUrl}');
    await db.insert('history', item.toJson());
    return item.id;
  }

  Future<List<HistoryItem>> getAllHistoryItems() async {
    if (kIsWeb) {
      final list = await _prefsLoadAll();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    final db = await database;
    final result = await db.query('history', orderBy: 'createdAt DESC');
    // Logging: fetched count
    // ignore: avoid_print
    print('[DB] Loaded all history items count=${result.length}');

    return result.map((json) => HistoryItem.fromJson(json)).toList();
  }

  Future<List<HistoryItem>> getFavoriteHistoryItems() async {
    if (kIsWeb) {
      final list = await _prefsLoadAll();
      final favs = list.where((e) => e.isFavorite).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return favs;
    }
    final db = await database;
    final result = await db.query(
      'history',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    // ignore: avoid_print
    print('[DB] Loaded favorite history items count=${result.length}');

    return result.map((json) => HistoryItem.fromJson(json)).toList();
  }

  Future<HistoryItem?> getHistoryItem(String id) async {
    if (kIsWeb) {
      final list = await _prefsLoadAll();
      try {
        return list.firstWhere((e) => e.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final result = await db.query('history', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      // ignore: avoid_print
      print('[DB] Loaded history item id=$id');
      return HistoryItem.fromJson(result.first);
    }
    // ignore: avoid_print
    print('[DB] History item not found id=$id');
    return null;
  }

  Future<void> updateHistoryItem(HistoryItem item) async {
    if (kIsWeb) {
      final list = await _prefsLoadAll();
      final idx = list.indexWhere((e) => e.id == item.id);
      if (idx >= 0) {
        list[idx] = item;
        await _prefsSaveAll(list);
      }
      return;
    }
    final db = await database;
    // ignore: avoid_print
    print('[DB] Updating history item id=${item.id}');
    await db.update(
      'history',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteHistoryItem(String id) async {
    if (kIsWeb) {
      final list = await _prefsLoadAll();
      list.removeWhere((e) => e.id == id);
      await _prefsSaveAll(list);
      return;
    }
    final db = await database;
    // ignore: avoid_print
    print('[DB] Deleting history item id=$id');
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllHistory() async {
    if (kIsWeb) {
      await _prefsSaveAll([]);
      return;
    }
    final db = await database;
    // ignore: avoid_print
    print('[DB] Clearing all history');
    await db.delete('history');
  }

  Future<void> toggleFavorite(String id) async {
    final item = await getHistoryItem(id);
    if (item != null) {
      // ignore: avoid_print
      print('[DB] Toggling favorite id=$id -> ${!item.isFavorite}');
      await updateHistoryItem(item.copyWith(isFavorite: !item.isFavorite));
    }
  }

  Future<List<HistoryItem>> searchHistory(String query) async {
    if (kIsWeb) {
      final list = await _prefsLoadAll();
      final q = query.toLowerCase();
      final filtered = list.where((e) {
        return e.originalUrl.toLowerCase().contains(q) ||
            e.cleanedUrl.toLowerCase().contains(q) ||
            e.domain.toLowerCase().contains(q);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    }
    final db = await database;
    final result = await db.query(
      'history',
      where: 'originalUrl LIKE ? OR cleanedUrl LIKE ? OR domain LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    // ignore: avoid_print
    print('[DB] Search "$query" results=${result.length}');

    return result.map((json) => HistoryItem.fromJson(json)).toList();
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    db.close();
  }

  // -------- Web storage (SharedPreferences) helpers ---------
  Future<List<HistoryItem>> _prefsLoadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> _prefsSaveAll(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsHistoryKey, encoded);
  }
}
