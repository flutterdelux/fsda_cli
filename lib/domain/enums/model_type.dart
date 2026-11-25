import 'package:collection/collection.dart';

enum ModelType {
  entity('entity'),
  param('param'),
  dto('dto'),
  request('request'),
  response('response');

  final String suffix;

  const ModelType(this.suffix);

  static ModelType? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.suffix == value);
  }

  static String get available => values.map((e) => e.suffix).join(', ');
}
