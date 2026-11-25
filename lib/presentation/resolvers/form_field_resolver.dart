import '../../core/constants/rules.dart';
import '../../domain/enums/input_type.dart';
import '../../domain/models/form_field_model.dart';

abstract final class FormFieldResolverKeys {
  static const inputType = 'input_type';
  static const valueType = 'value_type';
  static const fieldName = 'name';
  static const defaultValue = 'default';
}

abstract final class FormFieldResolver {
  static FormFieldModel resolve({required Map<String, dynamic> data}) {
    // ============ input_type ============
    final rawInputType = data[FormFieldResolverKeys.inputType];
    if (rawInputType == null) {
      throw const FormatException('Field "input_type" is required.');
    }
    if (rawInputType is! String) {
      throw const FormatException('Field "input_type" must be String type.');
    }

    final inputTypeStr = rawInputType.trim();
    if (inputTypeStr.isEmpty) {
      throw const FormatException('Field "input_type" cannot be empty.');
    }

    final inputType = InputType.tryParse(inputTypeStr);
    if (inputType == null) {
      throw FormatException(
        'Invalid input_type "$inputTypeStr".\n'
        'Supported input types: ${InputType.values.map((e) => e.name).join(', ')}.',
      );
    }

    // ============ value_type ============
    final rawValueType = data[FormFieldResolverKeys.valueType];
    if (rawValueType == null) {
      throw const FormatException('Field "value_type" is required.');
    }
    if (rawValueType is! String) {
      throw const FormatException('Field "value_type" must be String type.');
    }

    final valueType = rawValueType.trim();
    if (valueType.isEmpty) {
      throw const FormatException('Field "value_type" cannot be empty.');
    }

    // ============ name (field_name) ============
    final rawFieldName = data[FormFieldResolverKeys.fieldName];
    if (rawFieldName == null) {
      throw const FormatException('Field "name" is required.');
    }
    if (rawFieldName is! String) {
      throw const FormatException('Field "name" must be String type.');
    }

    final fieldName = rawFieldName.trim();
    if (fieldName.isEmpty) {
      throw const FormatException('Field "name" cannot be empty.');
    }

    if (!Rules.fieldNameRegExp.hasMatch(fieldName)) {
      throw FormatException(
        'Invalid field name: "$fieldName".\n'
        '${Rules.fieldNameDescription}',
      );
    }

    // ============ default (optional) ============
    final rawDefault = data[FormFieldResolverKeys.defaultValue];
    final defaultStr = rawDefault?.toString().trim() ?? '';

    return FormFieldModel(
      inputType: inputType,
      valueType: valueType,
      fieldName: fieldName,
      defaultValue: defaultStr.isNotEmpty ? defaultStr : null,
    );
  }

  /// An adapter for converting a raw delimiter string `"input_type:valueType:field_name[:default]"`
  /// into a canonical `Map<String, dynamic>`.
  static Map<String, dynamic> fromDelimiter(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Field string cannot be empty.');
    }

    final parts = trimmed.split(':');
    return {
      FormFieldResolverKeys.inputType: parts.isNotEmpty ? parts[0].trim() : '',
      FormFieldResolverKeys.valueType: parts.length > 1 ? parts[1].trim() : '',
      FormFieldResolverKeys.fieldName: parts.length > 2 ? parts[2].trim() : '',
      FormFieldResolverKeys.defaultValue: parts.length > 3
          ? parts[3].trim()
          : '',
    };
  }
}
