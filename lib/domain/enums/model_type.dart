import 'package:collection/collection.dart';

enum ModelType {
  entity('entity'),
  param('param'),
  dto('dto'),
  request('request'),
  response('response');

  final String value;

  const ModelType(this.value);

  static ModelType? fromValue(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  String resolveParentDirUnderFeature() {
    return switch (this) {
      .entity => 'domain/entities',
      .param => 'domain/params',
      .dto => 'data/dtos',
      .request => 'data/requests',
      .response => 'data/responses',
    };
  }
}
