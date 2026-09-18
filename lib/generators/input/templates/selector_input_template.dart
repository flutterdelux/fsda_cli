import 'package:mason/mason.dart';

String buildSelectorInputTemplate({
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
