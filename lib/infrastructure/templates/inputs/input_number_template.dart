import '../../../domain/params/input_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputNumberTemplate {
  static String build(InputParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final modulePascal = input.moduleName.pascalCase;
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final className = '$featurePascal${fieldPascal}Field';

    final type = input.dataType;
    final isIntegerType = type == 'int';
    final isDecimalType = type == 'double';

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
import 'package:flutter/services.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

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

  static Map<String, dynamic> buildArbEntries(InputParam input) {
    final entries = <String, dynamic>{};
    final featureCamel = input.featureName.camelCase;
    final featureSentence = input.featureName.sentenceCase;
    final fieldPascal = input.field.pascalCase;
    final fieldTitle = input.field.titleCase;
    final fieldSentence = input.field.sentenceCase;

    final key = '${featureCamel}Field$fieldPascal';
    entries['${key}Label'] = fieldTitle;
    entries['${key}Hint'] = 'Enter $featureSentence $fieldSentence...';
    entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';
    entries['${key}InvalidFormat'] = '$fieldTitle invalid format';

    return entries;
  }
}
