import 'package:app_core/app_core.dart';
import 'package:hive/hive.dart';

class HiveLocalStorage implements LocalStorage {
  final Box _box;

  const HiveLocalStorage({required Box box}) : _box = box;

  @override
  Future<void> write(String key, Object value) async {
    return switch (value) {
      String _ || int _ || double _ || bool _ => _box.put(key, value),
      _ => throw UnsupportedError(
        'Unsupported value type: ${value.runtimeType}',
      ),
    };
  }

  @override
  Object? read(String key) => _box.get(key);

  @override
  bool contains(String key) => _box.containsKey(key);

  @override
  Future<void> remove(String key) => _box.delete(key);

  @override
  Future<void> clear() => _box.clear();
}
