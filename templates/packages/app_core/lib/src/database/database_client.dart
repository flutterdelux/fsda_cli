abstract interface class DatabaseClient {
  Future<void> insert(String table, Map<String, Object?> values);

  Future<void> insertMany(String table, List<Map<String, Object?>> values);

  Future<void> update(String table, Object id, Map<String, Object?> values);

  Future<void> delete(String table, Object id);

  Future<void> clear(String table);

  Future<Map<String, Object?>?> findById(String table, Object id);

  Future<List<Map<String, Object?>>> findAll(String table);
}
