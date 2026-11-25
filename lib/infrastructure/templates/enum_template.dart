import '../../domain/params/enum_param.dart';
import '../text_modifiers/string_extension.dart';

abstract final class EnumTemplate {
  static String buildEnum(EnumParam enumParam) {
    final enumPascal = enumParam.enumName.pascalCase;
    final valueLines = enumParam.values
        .map((v) => '  ${v.camelCase},')
        .join('\n');

    return '''
enum $enumPascal {
$valueLines
}
''';
  }

  static String buildConverter(EnumParam enumParam) {
    final enumSnake = enumParam.enumName;
    final enumPascal = enumSnake.pascalCase;

    final values = enumParam.values;

    final fromJsonCases = values
        .map((v) {
          final value = enumParam.isLower ? v.toLowerCase() : v.toUpperCase();
          final camelValue = v.camelCase;
          return "      '$value' => $enumPascal.$camelValue,";
        })
        .join('\n');

    final toJsonCases = values
        .map((v) {
          final value = enumParam.isLower ? v.toLowerCase() : v.toUpperCase();
          final camelValue = v.camelCase;
          return "      $enumPascal.$camelValue => '$value',";
        })
        .join('\n');

    final className = '${enumPascal}Converter';
    return '''
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/enums/$enumSnake.dart';

class $className extends JsonConverter<$enumPascal, String> {
  const $className();

  @override
  $enumPascal fromJson(String json) {
    return switch (json) {
$fromJsonCases
      _ => throw ArgumentError('Invalid $enumSnake: \$json'),
    };
  }

  @override
  String toJson($enumPascal object) {
    return switch (object) {
$toJsonCases
    };
  }
}
''';
  }

  static String buildExtension(EnumParam enumParam) {
    final enumSnake = enumParam.enumName;
    final enumCamel = enumSnake.camelCase;
    final enumPascal = enumSnake.pascalCase;

    final moduleSnake = enumParam.moduleName;
    final modulePascal = moduleSnake.pascalCase;

    final values = enumParam.values;

    final localizeCases = values
        .map((v) {
          final camelValue = v.camelCase;
          final pascalValue = v.pascalCase;
          final key = '$enumCamel${pascalValue}Label';
          return "      $enumPascal.$camelValue => l10n.$key,";
        })
        .join('\n');

    final localizeDescCases = values
        .map((v) {
          final valueCamel = v.camelCase;
          final valuePascal = v.pascalCase;
          final key = '$enumCamel${valuePascal}Description';
          return "      $enumPascal.$valueCamel => l10n.$key,";
        })
        .join('\n');

    final boolGetters = values
        .map((v) {
          final valueCamel = v.camelCase;
          final valuePascal = v.pascalCase;
          return '  bool get is$valuePascal => this == $enumPascal.$valueCamel;';
        })
        .join('\n');

    return '''
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleSnake}_localizations.dart';
import '../../../domain/enums/$enumSnake.dart';

extension ${enumPascal}X on $enumPascal {
  String localize(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    return switch (this) {
$localizeCases
    };
  }

  String localizeDescription(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    return switch (this) {
$localizeDescCases
    };
  }

$boolGetters
}
''';
  }

  static Map<String, dynamic> buildArbEntries(EnumParam enumParam) {
    final enumSnake = enumParam.enumName;
    final enumCamel = enumSnake.camelCase;

    final entries = <String, dynamic>{};

    final enumKey = enumCamel;
    entries[enumKey] = enumSnake.titleCase;

    final values = enumParam.values;
    for (final v in values) {
      final valuePascal = v.pascalCase;
      final labelKey = '$enumCamel${valuePascal}Label';
      final descKey = '$enumCamel${valuePascal}Description';

      entries[labelKey] = v.titleCase;
      entries[descKey] = 'Description for ${v.titleCase}';
    }

    return entries;
  }
}
