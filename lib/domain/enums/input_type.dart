import 'package:collection/collection.dart';

enum InputType {
  dropdownEnum('dropdown_enum'),
  dropdown('dropdown'),
  image('image'),
  number('number'),
  password('password'),
  qty('qty'),
  selectorList('selector_list'),
  selector('selector'),
  swich('switch'),
  textArea('text_area'),
  text('text');

  final String code;

  const InputType(this.code);

  static InputType? tryParse(String raw) {
    return values.firstWhereOrNull((e) => e.code == raw);
  }
}
