import 'dart:convert';

import 'package:mason/mason.dart';

import '../../../enums/input_code.dart';
import '../../../models/generation/typed_prop.dart';
import '../templates/dropdown_enum_input_template.dart';
import '../templates/dropdown_input_template.dart';
import '../templates/image_input_template.dart';
import '../templates/password_input_template.dart';
import '../templates/qty_input_template.dart';
import '../templates/selector_input_template.dart';
import '../templates/selector_list_input_template.dart';
import '../templates/switch_input_template.dart';
import '../templates/text_area_input_template.dart';
import '../templates/text_input_template.dart';

class InputWidgetFileBuilderService {
  const InputWidgetFileBuilderService();

  Map<String, List<int>> buildCodeDrivenFiles({
    required String featureName,
    required String moduleName,
    required List<String> fields,
    required InputCode inputCode,
  }) {
    final files = <String, List<int>>{};

    for (final field in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: field,
      );
      files[relativePath] = utf8.encode(
        _buildCodeDrivenSource(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: field,
          inputCode: inputCode,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildTextTypedFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildTextInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          typeName: item.normalizedType,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildTextAreaTypedFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
    required int minLines,
    required int maxLines,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildTextAreaInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          minLines: minLines,
          maxLines: maxLines,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildTextQtyFiles({
    required String featureName,
    required String moduleName,
    required List<String> fields,
  }) {
    final files = <String, List<int>>{};
    for (final field in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: field,
      );
      files[relativePath] = utf8.encode(
        buildQtyInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: field,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildDropdownEnumFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildDropdownEnumInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          enumType: item.typeWithoutNullability,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildDropdownFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildDropdownInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          typeName: item.normalizedType,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildSelectorFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildSelectorInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          valueType: item.typeWithoutNullability,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildSelectorListFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildSelectorListInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          valueType: item.typeWithoutNullability,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildImageFiles({
    required String featureName,
    required String moduleName,
    required List<TypedProp> fields,
  }) {
    final files = <String, List<int>>{};
    for (final item in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: item.name,
      );
      files[relativePath] = utf8.encode(
        buildImageInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: item.name,
          valueType: item.typeWithoutNullability,
        ),
      );
    }

    return files;
  }

  Map<String, List<int>> buildSwitchFiles({
    required String featureName,
    required String moduleName,
    required List<String> fields,
  }) {
    final files = <String, List<int>>{};
    for (final field in fields) {
      final relativePath = _sharedFieldPath(
        featureName: featureName,
        fieldName: field,
      );
      files[relativePath] = utf8.encode(
        buildSwitchInputTemplate(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: field,
        ),
      );
    }

    return files;
  }

  String _sharedFieldPath({
    required String featureName,
    required String fieldName,
  }) {
    return 'ui/shared/widgets/${featureName.snakeCase}_${fieldName.snakeCase}_field.dart';
  }

  String _buildCodeDrivenSource({
    required String moduleName,
    required String featureName,
    required String fieldName,
    required InputCode inputCode,
  }) {
    return switch (inputCode) {
      InputCode.text => buildTextInputTemplate(
        moduleName: moduleName,
        featureName: featureName,
        fieldName: fieldName,
      ),
      InputCode.password => buildPasswordInputTemplate(
        moduleName: moduleName,
        featureName: featureName,
        fieldName: fieldName,
      ),
      InputCode.dropdown || InputCode.dropdownEnum => throw UnsupportedError(
        'Dropdown generation uses dedicated methods.',
      ),
    };
  }
}
