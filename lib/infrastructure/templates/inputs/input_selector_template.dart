import '../../../domain/params/inputs/input_selector_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputSelectorTemplate {
  static String build(InputSelectorParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final modulePascal = input.moduleName.pascalCase;
    final className = '$featurePascal${fieldPascal}Field';
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final valueType = input.valueType;

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

class $className extends StatelessWidget {
  final $valueType? selectedValue;
  final Future<void> Function($valueType? currentSelected)? onSelect;
  final VoidCallback? onClear;

  const $className({
    super.key,
    required this.selectedValue,
    this.onSelect,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppTextField(
        key: ValueKey(selectedValue?.name),
        initialValue: selectedValue?.name ?? '',
        hintText: l10n.${l10nKey}Hint,
        readOnly: true,
        onTap: onSelect != null ? () => onSelect!(selectedValue) : null,
        suffix: UnconstrainedBox(
          child: AppInputFieldAction(
            hasValue: selectedValue != null,
            onClear: onClear,
            onPressed: onSelect != null ? () => onSelect!(selectedValue) : null,
          ),
        ),
      ),
    );
  }
}
''';
  }

  static Map<String, dynamic> buildArbEntries(InputSelectorParam input) {
    final entries = <String, dynamic>{};
    final featureCamel = input.featureName.camelCase;
    final fieldPascal = input.field.pascalCase;
    final fieldTitle = input.field.titleCase;

    final key = '${featureCamel}Field$fieldPascal';
    entries['${key}Label'] = fieldTitle;
    entries['${key}Hint'] = 'Select $fieldTitle...';
    entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';

    return entries;
  }
}
