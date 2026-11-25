import '../../core/constants/rules.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/feature_param.dart';

abstract final class EnumResolverKeys {
  /// `name`
  static const name = 'name';

  /// `values`
  static const values = 'values';

  /// `lower`
  static const isLower = 'lower';
}

abstract final class EnumResolver {
  static String resolveName(Map<String, dynamic> data) {
    final rawName = data[EnumResolverKeys.name];
    if (rawName == null) {
      throw const FormatException('Enum name is required.');
    }
    if (rawName is! String) {
      throw const FormatException('Enum name must be String type.');
    }

    final enumName = rawName.trim();
    if (!Rules.enumRegExp.hasMatch(enumName)) {
      throw const FormatException(
        'Invalid enum name.\n'
        '${Rules.enumDescription}',
      );
    }

    return enumName;
  }

  static EnumParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ enumName ============
    final enumName = resolveName(data);

    // ============ values ============
    final rawValues = data[EnumResolverKeys.values];
    if (rawValues == null) {
      throw const FormatException('Enum values is required.');
    }
    if (rawValues is! String) {
      throw const FormatException('Enum values must be String type.');
    }

    final enumValues = <String>[];
    for (final value in rawValues.split(',')) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;

      if (!Rules.enumValueRegExp.hasMatch(trimmed)) {
        throw const FormatException(
          'Invalid enum value.\n'
          '${Rules.enumValueDescription}',
        );
      }

      enumValues.add(trimmed);
    }

    if (enumValues.isEmpty) {
      throw const FormatException('At least one enum value is required.');
    }

    // ============ isLower ============
    final rawIsLower = data[EnumResolverKeys.isLower] ?? false;
    if (rawIsLower is! bool) {
      throw const FormatException('Lower must be bool type.');
    }

    return EnumParam.fromFeature(
      feature: feature,
      enumName: enumName,
      values: enumValues,
      isLower: rawIsLower,
    );
  }
}
