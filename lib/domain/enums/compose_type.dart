import 'package:collection/collection.dart';

enum ComposeType {
  mutation('m'),
  retrieval('r'),
  pagination('pag'),
  form('form');

  final String value;

  const ComposeType(this.value);

  static ComposeType? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
