import 'package:collection/collection.dart';

enum DsMode {
  local('local'),
  remote('remote');

  final String value;

  const DsMode(this.value);

  static DsMode? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
