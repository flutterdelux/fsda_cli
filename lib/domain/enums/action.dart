import 'package:collection/collection.dart';

enum Action {
  post('post'),
  get('get'),
  put('put'),
  patch('patch'),
  delete('delete');

  final String value;

  const Action(this.value);

  static Action? tryParse(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static String get available => values.map((e) => e.value).join(', ');
}
