import 'package:collection/collection.dart';

enum StateControl {
  cubit('cubit'),
  getx('getx'),
  provider('provider'),
  riverpod('riverpod');

  final String value;

  const StateControl(this.value);

  static StateControl? tryParse(String? value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }

  static StateControl? parseFromExtends(String parentClass) {
    return switch (parentClass) {
      'Cubit' => .cubit,
      'GetxController' => .getx,
      'ChangeNotifier' => .provider,
      'Notifier' => .riverpod,
      _ => null,
    };
  }

  static String get available => values.map((e) => e.value).join(', ');
}
