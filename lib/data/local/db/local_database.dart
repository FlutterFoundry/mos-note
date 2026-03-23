import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:memos_note/core/constants/app_constants.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memos (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        content TEXT NOT NULL,
        creator TEXT,
        create_time TEXT,
        update_time TEXT,
        display_time TEXT,
        visibility TEXT,
        pinned INTEGER DEFAULT 0,
        row_status TEXT,
        tags_json TEXT,
        attachments_json TEXT,
        synced INTEGER DEFAULT 0,
        local_updated INTEGER DEFAULT 0,
        is_local_only INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_ops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        op_type TEXT NOT NULL,
        memo_id TEXT,
        payload TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add is_local_only flag for memos created while offline
      await db.execute(
          'ALTER TABLE memos ADD COLUMN is_local_only INTEGER DEFAULT 0');
      // Add retry_count to pending_ops if not present
      try {
        await db.execute(
            'ALTER TABLE pending_ops ADD COLUMN retry_count INTEGER DEFAULT 0');
      } catch (_) {
        // Column already exists on fresh installs
      }
    }
    if (oldVersion < 3) {
      // Rename resources_json to attachments_json
      try {
        await db.execute(
            'ALTER TABLE memos RENAME COLUMN resources_json TO attachments_json');
      } catch (_) {
        // Column might already be renamed or fresh install
      }
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
