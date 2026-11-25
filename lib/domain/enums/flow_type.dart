import 'package:collection/collection.dart';

enum FlowType {
  synchronous('sync'),
  asynchronous('async'),
  stream('stream');

  final String value;

  const FlowType(this.value);

  static FlowType? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
