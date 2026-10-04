import 'package:mason/mason.dart';

String buildSwitchInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final modulePascal = moduleName.pascalCase;
  final className = '$featurePascal${fieldPascal}Field';
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class $className extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const $className({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppTextField(
        key: ValueKey(value),
        initialValue: value ? 'Available' : 'Not Available',
        hintText: l10n.${l10nKey}Hint,
        readOnly: true,
        onTap: () => onChanged(!value),
        suffix: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: colorScheme.primary,
        ),
      ),
    );
  }
}
''';
}
