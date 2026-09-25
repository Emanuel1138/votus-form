import 'package:sembast/sembast.dart';

import 'database_factory.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Database? _db;

  final StoreRef<int, Map<String, dynamic>> _store =
      intMapStoreFactory.store('responses');

  Future<Database> get database async {
    _db ??= await openSurveyDatabase();
    return _db!;
  }

  Future<int> insertResponse({
    required String deviceId,
    required String answersJson,
    required String answeredAt,
  }) async {
    final db = await database;

    return _store.add(db, {
      'device_id': deviceId,
      'answers': answersJson,
      'answered_at': answeredAt,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingResponses() async {
    final db = await database;

    final finder = Finder(
      filter: Filter.equals('synced', 0),
    );

    final records = await _store.find(
      db,
      finder: finder,
    );

    return records.map((record) {
      return {
        'id': record.key,
        ...record.value,
      };
    }).toList();
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;

    await _store.record(id).update(db, {
      'synced': 1,
    });
  }
}