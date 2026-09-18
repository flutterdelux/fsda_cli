import 'package:mason/mason.dart';

String buildDropdownEnumInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
  required String enumType,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final className = '$featurePascal${fieldPascal}Field';

  return '''import 'package:app_core/app_core.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';
import '../../../domain/enums/${enumType.snakeCase}.dart';
import '../extensions/${enumType.snakeCase}_x.dart';

class $className extends StatelessWidget {
  final ValueChanged<$enumType?>? onSelected;
  final $enumType? selection;

  const $className({
    super.key,
    this.onSelected,
    this.selection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ${moduleName.pascalCase}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppDropdownField<$enumType>(
        initialSelection: selection,
        onSelected: onSelected,
        hintText: l10n.${l10nKey}Hint,
        menuEntries: $enumType.values.map((entry) {
          return DropdownMenuEntry<$enumType>(
            value: entry,
            label: entry.localize(context),
          );
        }).toList(),
      ),
    );
  }
}
''';
}
