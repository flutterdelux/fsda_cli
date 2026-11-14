import '../../../domain/params/inputs/input_switch_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputSwitchTemplate {
  static String build(InputSwitchParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final modulePascal = input.moduleName.pascalCase;
    final className = '$featurePascal${fieldPascal}Field';
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

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
        initialValue: value ? 'Active' : 'Inactive',
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

  static Map<String, dynamic> buildArbEntries(InputSwitchParam input) {
    final entries = <String, dynamic>{};
    final featureCamel = input.featureName.camelCase;
    final featureSentence = input.featureName.sentenceCase;
    final fieldPascal = input.field.pascalCase;
    final fieldTitle = input.field.titleCase;
    final fieldSentence = input.field.sentenceCase;

    final key = '${featureCamel}Field$fieldPascal';
    entries['${key}Label'] = fieldTitle;
    entries['${key}Hint'] = 'Toggle $featureSentence $fieldSentence...';

    return entries;
  }
}
