import 'package:mason/mason.dart';

String buildSelectorListInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
  required String valueType,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final modulePascal = moduleName.pascalCase;
  final className = '$featurePascal${fieldPascal}Field';
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';
import '../../../domain/entities/${valueType.snakeCase}.dart';

class $className extends StatelessWidget {
  final List<$valueType> selectedValues;
  final Future<void> Function(List<$valueType> currentSelected)? onSelect;
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
