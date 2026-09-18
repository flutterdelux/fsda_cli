import 'package:mason/mason.dart';

String buildTextAreaInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
  required int minLines,
  required int maxLines,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final modulePascal = moduleName.pascalCase;
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final className = '$featurePascal${fieldPascal}Field';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

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
        minLines: $minLines,
        maxLines: $maxLines,
      ),
    );
  }
}
''';
}
