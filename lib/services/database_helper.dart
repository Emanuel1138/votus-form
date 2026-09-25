import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'survey.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE responses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT NOT NULL,
            answers TEXT NOT NULL,
            answered_at TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertResponse({
    required String deviceId,
    required String answersJson,
    required String answeredAt,
  }) async {
    final db = await database;
    return db.insert('responses', {
      'device_id': deviceId,
      'answers': answersJson,
      'answered_at': answeredAt,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingResponses() async {
    final db = await database;
    return db.query('responses', where: 'synced = 0');
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update('responses', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}