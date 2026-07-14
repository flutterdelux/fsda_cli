import 'package:app_core/app_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocalStorage implements LocalStorage {
  final SharedPreferences _prefs;

  const SharedPreferencesLocalStorage({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  @override
  Future<void> write(String key, Object value) {
    return switch (value) {
      String _ => _prefs.setString(key, value),
      int _ => _prefs.setInt(key, value),
      double _ => _prefs.setDouble(key, value),
      bool _ => _prefs.setBool(key, value),
      _ => throw UnsupportedError(
        'Unsupported value type: ${value.runtimeType}',
      ),
    };
  }

  @override
  Object? read(String key) => _prefs.get(key);

  @override
  bool contains(String key) => _prefs.containsKey(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}
