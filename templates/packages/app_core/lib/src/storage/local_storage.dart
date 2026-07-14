abstract interface class LocalStorage {
  Future<void> write(String key, Object value);

  Object? read(String key);

  bool contains(String key);

  Future<void> remove(String key);

  Future<void> clear();
}
