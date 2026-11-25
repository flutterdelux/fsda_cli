import '../../../domain/params/input_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputSelectorListTemplate {
  static String build(InputParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final modulePascal = input.moduleName.pascalCase;
    final className = '$featurePascal${fieldPascal}Field';
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final dataType = input.dataType;

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

class $className extends StatelessWidget {
  final List<$dataType> selectedValues;
  final Future<void> Function(List<$dataType> currentSelected)? onSelect;
  final VoidCallback? onClear;

  const $className({
    super.key,
    required this.selectedValues,
    this.onSelect,
    this.onClear,
  });

  String _renderSelectedText() {
    if (selectedValues.isEmpty) {
      return '';
    }

    return selectedValues.map((item) => item.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ${modulePascal}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppTextField(
        key: ValueKey(selectedValues.length),
        initialValue: _renderSelectedText(),
        hintText: l10n.${l10nKey}Hint,
        readOnly: true,
        onTap: onSelect != null ? () => onSelect!(selectedValues) : null,
        suffix: UnconstrainedBox(
          child: AppInputFieldAction(
            hasValue: selectedValues.isNotEmpty,
            onClear: onClear,
            onPressed: onSelect != null ? () => onSelect!(selectedValues) : null,
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
    entries['${key}Hint'] = 'Select $fieldTitle...';
    entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';

    return entries;
  }
}
