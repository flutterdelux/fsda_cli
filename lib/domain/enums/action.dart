import 'package:collection/collection.dart';

enum Action {
  post('post'),
  get('get'),
  put('put'),
  patch('patch'),
  delete('delete');

  final String value;

  const Action(this.value);

  static Action? fromValue(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}
