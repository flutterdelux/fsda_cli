import '../../../domain/params/input_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputQtyTemplate {
  static String build(InputParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final className = '$featurePascal${fieldPascal}Field';

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

class $className extends StatelessWidget {
  final TextEditingController controller;

  const $className({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = ${input.moduleName.pascalCase}Localizations.of(context)!;
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

  static Map<String, dynamic> buildArbEntries(InputParam input) {
    final entries = <String, dynamic>{};
    final featureCamel = input.featureName.camelCase;
    final fieldPascal = input.field.pascalCase;
    final fieldTitle = input.field.titleCase;

    final key = '${featureCamel}Field$fieldPascal';
    entries['${key}Label'] = fieldTitle;
    entries['${key}Hint'] = 'Enter $fieldTitle...';
    entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';
    entries['${key}InvalidFormat'] = '$fieldTitle invalid format';

    return entries;
  }
}
