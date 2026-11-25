import 'package:collection/collection.dart';

enum UiType {
  standard('standard'),
  form('form'),
  lsh('lsh'),
  lsv('lsv'),
  pag('pag');

  final String value;

  const UiType(this.value);

  static UiType? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
