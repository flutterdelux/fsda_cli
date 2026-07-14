import 'package:app_core/app_core.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatabaseClient implements DatabaseClient {
  final Database _database;

  const SqfliteDatabaseClient({required Database database})
    : _database = database;

  @override
  Future<void> insert(String table, Map<String, Object?> values) {
    return _database.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertMany(
    String table,
    List<Map<String, Object?>> values,
  ) async {
    await _database.transaction((txn) async {
      final batch = txn.batch();

      for (final item in values) {
        batch.insert(table, item, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> update(String table, Object id, Map<String, Object?> values) {
    return _database.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Map<String, Object?>?> findById(String table, Object id) async {
    final result = await _database.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.firstOrNull;
  }

  @override
  Future<List<Map<String, Object?>>> findAll(String table) {
    return _database.query(table);
  }

  @override
  Future<void> delete(String table, Object id) {
    return _database.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clear(String table) {
    return _database.delete(table);
  }
}
