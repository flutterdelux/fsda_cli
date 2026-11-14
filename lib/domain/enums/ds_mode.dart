import 'package:collection/collection.dart';

enum DsMode {
  local('local'),
  remote('remote');

  final String value;

  const DsMode(this.value);

  static DsMode? fromValue(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}
