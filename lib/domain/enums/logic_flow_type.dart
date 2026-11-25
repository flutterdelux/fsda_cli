import 'package:collection/collection.dart';

enum LogicFlowType {
  mutation('m'),
  retrieval('r'),
  pagination('pag');

  final String value;

  const LogicFlowType(this.value);

  static LogicFlowType? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
