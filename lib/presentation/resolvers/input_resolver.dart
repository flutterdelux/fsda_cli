import '../../core/constants/rules.dart';
import '../../domain/enums/input_type.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/input_param.dart';

abstract final class InputResolverKeys {
  /// `type`
  static const type = 'type';

  /// `field`
  static const field = 'field';

  /// `data-type`
  static const dataType = 'data-type';

  /// `min`
  static const min = 'min';

  /// `max`
  static const max = 'max';

  /// `list`
  static const isList = 'list';
}

abstract final class InputResolver {
  static const defaultMinLines = 3;
  static const defaultMaxLines = 3;
  static const defaultNumberType = 'int';
  static const supportedNumberTypes = [defaultNumberType, 'double'];
  static const defaultImageType = 'NetworkFile';

  static InputParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ type ============
    final rawType = data[InputResolverKeys.type];
    if (rawType == null || (rawType is String && rawType.trim().isEmpty)) {
      throw FormatException(
        'Input type is required. Available: ${InputType.available}.',
      );
    }
    if (rawType is! String) {
      throw const FormatException('Input type must be String type.');
    }

    final typeStr = rawType.trim().toLowerCase();
    final inputType = InputType.tryParse(typeStr);
    if (inputType == null) {
      throw FormatException(
        'Invalid input type: "$typeStr". Available: ${InputType.available}.',
      );
    }

    // ============ field ============
    final rawField = data[InputResolverKeys.field];
    if (rawField == null || (rawField is String && rawField.trim().isEmpty)) {
      throw const FormatException('Field name is required.');
    }
    if (rawField is! String) {
      throw const FormatException('Field name must be String type.');
    }

    final field = rawField.trim();
    if (!Rules.fieldNameRegExp.hasMatch(field)) {
      throw FormatException(
        'Invalid field name: "$field".\n'
        '${Rules.fieldNameDescription}',
      );
    }

    // ============ variant-specific options ============
    final String? dataType;
    int minLines = 3;
    int maxLines = 3;
    bool isList = false;

    switch (inputType) {
      case InputType.text:
      case InputType.swich:
      case InputType.password:
      case InputType.qty:
        dataType = null;
        break;
      case InputType.textArea:
        dataType = null;
        minLines = _parseInt(
          raw: data[InputResolverKeys.min],
          label: 'min',
          defaultValue: defaultMinLines,
        );
        maxLines = _parseInt(
          raw: data[InputResolverKeys.max],
          label: 'max',
          defaultValue: defaultMaxLines,
        );

        if (minLines < 1) {
          throw const FormatException('Minimum lines must be at least 1.');
        }
        if (maxLines < minLines) {
          throw FormatException(
            'Maximum lines ($maxLines) cannot be less than minimum lines ($minLines).',
          );
        }
        break;
      case InputType.number:
        final resolved = _resolveOptionalDataType(
          data,
          defaultType: defaultNumberType,
        );
        if (!supportedNumberTypes.contains(resolved)) {
          throw FormatException(
            'Invalid number data-type: "$resolved". Supported types: ${supportedNumberTypes.join(', ')}.',
          );
        }
        dataType = resolved;
        break;
      case InputType.image:
        dataType = _resolveOptionalDataType(
          data,
          defaultType: defaultImageType,
        );
        break;
      case InputType.dropdown:
        dataType = _resolveRequiredDataType(data, label: 'Dropdown');
        break;
      case InputType.dropdownEnum:
        dataType = _resolveRequiredDataType(data, label: 'Dropdown enum');
        break;
      case InputType.selector:
        dataType = _resolveRequiredDataType(data, label: 'Selector');
        final rawList = data[InputResolverKeys.isList] ?? false;
        if (rawList is! bool) {
          throw const FormatException('List flag must be bool type.');
        }
        isList = rawList;
        break;
    }

    return InputParam.fromFeature(
      feature: feature,
      type: inputType,
      field: field,
      dataType: dataType,
      minLines: minLines,
      maxLines: maxLines,
      isList: isList,
    );
  }

  static String _resolveRequiredDataType(
    Map<String, dynamic> data, {
    required String label,
  }) {
    final raw = data[InputResolverKeys.dataType];
    if (raw == null || (raw is String && raw.trim().isEmpty)) {
      throw FormatException('$label data-type is required.');
    }
    if (raw is! String) {
      throw const FormatException('Data type must be String type.');
    }
    return raw.trim();
  }

  static String _resolveOptionalDataType(
    Map<String, dynamic> data, {
    required String defaultType,
  }) {
    final raw = data[InputResolverKeys.dataType];
    if (raw == null || (raw is String && raw.trim().isEmpty)) {
      return defaultType;
    }
    if (raw is! String) {
      throw const FormatException('Data type must be String type.');
    }
    return raw.trim();
  }

  static int _parseInt({
    required dynamic raw,
    required String label,
    required int defaultValue,
  }) {
    if (raw == null) return defaultValue;
    if (raw is int) return raw;
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return defaultValue;
      final parsed = int.tryParse(trimmed);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid $label value: "$raw". Must be an integer.');
  }
}
