import 'package:collection/collection.dart';

enum PlanType {
  module('module'),
  feature('feature'),
  app('app');

  final String value;
  const PlanType(this.value);

  static PlanType? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
