import 'package:collection/collection.dart';

enum FlowType {
  synchronous('sync'),
  asynchronous('async'),
  stream('stream');

  final String value;

  const FlowType(this.value);

  static FlowType? fromValue(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}
