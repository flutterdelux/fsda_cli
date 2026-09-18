import '../../enums/form_input_type.dart';
import 'typed_prop.dart';

class InputTypedField {
  const InputTypedField({required this.prop, required this.inputType});

  final TypedProp prop;
  final FormInputType inputType;

  String get type => prop.type;

  String get name => prop.name;

  String? get defaultValue => prop.defaultValue;

  String get normalizedType => prop.normalizedType;

  bool get isNullable => prop.isNullable;

  String get typeWithoutNullability => prop.typeWithoutNullability;

  bool get hasDefault => prop.hasDefault;

  bool get isRequired => prop.isRequired;
}
