import '../../core/constants/rules.dart';
import '../../domain/models/prop_model.dart';

abstract final class PropResolverKeys {
  static const type = 'type';
  static const name = 'name';
  static const defaultValue = 'default';
  static const converter = 'converter';
}

abstract final class PropResolver {
  const PropResolver();

  static PropModel resolve({required Map<String, dynamic> data}) {
    // ============ type ============
    final rawType = data[PropResolverKeys.type];
    if (rawType == null) {
      throw const FormatException('Property "type" is required.');
    }
    if (rawType is! String) {
      throw const FormatException('Property "type" must be String type.');
    }
    final type = rawType.trim();
    if (type.isEmpty) {
      throw const FormatException('Property "type" cannot be empty.');
    }

    // ============ name ============
    final rawName = data[PropResolverKeys.name];
    if (rawName == null) {
      throw const FormatException('Property "name" is required.');
    }
    if (rawName is! String) {
      throw const FormatException('Property "name" must be String type.');
    }
    final propName = rawName.trim();
    if (propName.isEmpty) {
      throw const FormatException('Property "name" cannot be empty.');
    }
    if (!Rules.propNameRegExp.hasMatch(propName)) {
      throw FormatException(
        'Invalid property name "$propName".\n'
        '${Rules.propNameDescription}',
      );
    }

    // ============ default (optional) ============
    final rawDefault = data[PropResolverKeys.defaultValue] ?? '';
    final defaultValue = rawDefault.toString().trim();

    // ============ converter (optional) ============
    final rawConverter = data[PropResolverKeys.converter] ?? '';
    if (rawConverter is! String) {
      throw const FormatException('Property "converter" must be String type.');
    }
    final converter = rawConverter.trim();
    if (converter.isNotEmpty &&
        !Rules.propConverterRegExp.hasMatch(converter)) {
      throw FormatException(
        'Invalid converter name "$converter".\n'
        '${Rules.propConverterDescription}',
      );
    }

    return PropModel(
      type: type,
      name: propName,
      defaultValue: defaultValue,
      converter: converter,
    );
  }

  /// An adapter for converting a raw delimiter string `"Type:name[:default[:converter]]"`
  /// into a canonical `Map<String, dynamic>`.
  static Map<String, dynamic> fromDelimiter(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Property string cannot be empty.');
    }

    final parts = trimmed.split(':');
    return {
      PropResolverKeys.type: parts.isNotEmpty ? parts[0].trim() : '',
      PropResolverKeys.name: parts.length > 1 ? parts[1].trim() : '',
      PropResolverKeys.defaultValue: parts.length > 2 ? parts[2].trim() : '',
      PropResolverKeys.converter: parts.length > 3 ? parts[3].trim() : '',
    };
  }
}
