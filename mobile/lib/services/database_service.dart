import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:traceoff_mobile/models/history_item.dart';

class DatabaseService {
  const DatabaseService._init();

  static const DatabaseService instance = DatabaseService._init();
  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database not supported on web');
    }
    if (_database != null) return _database!;
    _database = await _initDB('traceoff.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
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
      },
    );
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
R        isFavorite $boolType,
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
    final db = await database;
    // Logging: inserting history item
    // ignore: avoid_print
    print(
        '[DB] Inserting history item for domain=${item.domain} cleanedUrl=${item.cleanedUrl}');
    await db.insert('history', item.toJson());
    return item.id;
  }

  Future<List<HistoryItem>> getAllHistoryItems() async {
    final db = await database;
    final result = await db.query('history', orderBy: 'createdAt DESC');
    // Logging: fetched count
    // ignore: avoid_print
    print('[DB] Loaded all history items count=${result.length}');

    return result.map((json) => HistoryItem.fromJson(json)).toList();
  }

  Future<List<HistoryItem>> getFavoriteHistoryItems() async {
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
    final db = await database;
    // ignore: avoid_print
    print('[DB] Deleting history item id=$id');
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllHistory() async {
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
    final db = await database;
    db.close();
  }
}
