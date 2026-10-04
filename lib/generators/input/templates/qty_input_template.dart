import 'package:mason/mason.dart';

String buildQtyInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final className = '$featurePascal${fieldPascal}Field';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class $className extends StatelessWidget {
  final TextEditingController controller;

  const $className({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = ${moduleName.pascalCase}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppTextField(
        controller: controller,
        hintText: l10n.${l10nKey}Hint,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        prefix: UnconstrainedBox(
          child: IconButton.filledTonal(
            onPressed: () {
              final currentValue = int.tryParse(controller.text) ?? 0;
              if (currentValue > 1) {
                controller.text = (currentValue - 1).toString();
              }
            },
            icon: const Icon(Icons.remove),
          ),
        ),
        suffix: UnconstrainedBox(
          child: IconButton.filledTonal(
            onPressed: () {
              final currentValue = int.tryParse(controller.text) ?? 0;
              controller.text = (currentValue + 1).toString();
            },
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
''';
}
