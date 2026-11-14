import 'package:collection/collection.dart';

enum LogicFlowType {
  mutation('m'),
  retrieval('r'),
  pagination('pag');

  final String value;

  const LogicFlowType(this.value);

  static LogicFlowType? fromvalue(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}
