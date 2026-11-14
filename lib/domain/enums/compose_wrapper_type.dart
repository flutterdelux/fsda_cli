import 'package:collection/collection.dart';

enum ComposeWrapperType {
  page('page'),
  section('section'),
  sheet('sheet'),
  dialog('dialog');

  final String value;
  const ComposeWrapperType(this.value);

  static ComposeWrapperType? tryParse(String? value) {
    return ComposeWrapperType.values.firstWhereOrNull((e) => e.value == value);
  }
}
