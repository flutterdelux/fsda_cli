import 'package:mason/mason.dart';

String buildTextInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
  String typeName = 'String',
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final modulePascal = moduleName.pascalCase;
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final className = '$featurePascal${fieldPascal}Field';
  final normalizedType = typeName.replaceAll(' ', '').replaceAll('?', '');
  final isIntegerType = normalizedType == 'int' || normalizedType == 'BigInt';
  final isDecimalType = normalizedType == 'double' || normalizedType == 'num';
  final isNumericType = isIntegerType || isDecimalType;

  final extraInputConfig = isIntegerType
      ? '''
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],'''
      : isDecimalType
      ? '''
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\\d*\\.?\\d*\$')),
        ],'''
      : '';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
${isNumericType ? "import 'package:flutter/services.dart';" : ''}

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class $className extends StatelessWidget {
  final TextEditingController controller;

  const $className({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppTextField(
        controller: controller,
        hintText: l10n.${l10nKey}Hint,
$extraInputConfig
      ),
    );
  }
}
''';
}
