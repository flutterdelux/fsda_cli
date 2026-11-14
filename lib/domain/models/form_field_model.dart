import '../enums/input_type.dart';

class FormFieldModel {
  final InputType inputType;
  final String valueType;
  final String fieldName;
  final String? defaultValue;

  const FormFieldModel({
    required this.inputType,
    required this.valueType,
    required this.fieldName,
    this.defaultValue,
  });
}
