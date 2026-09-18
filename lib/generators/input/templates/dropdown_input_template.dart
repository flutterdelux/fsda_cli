import 'package:mason/mason.dart';

String buildDropdownInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
  required String typeName,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final className = '$featurePascal${fieldPascal}Field';
  final selectionType = typeName.endsWith('?') ? typeName : '$typeName?';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';
import '../../../domain/entities/${typeName.snakeCase}.dart';

class $className extends StatelessWidget {
  final List<$typeName> items;
  final ValueChanged<$typeName?>? onSelected;
  final $selectionType selection;

  const $className({
    super.key,
    this.items = const [],
    this.onSelected,
    this.selection,
  });

  List<DropdownMenuEntry<$typeName>> _buildEntries() {
    return items
        .map((item) => DropdownMenuEntry<$typeName>(
              value: item,
              label: item.name,
            ))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ${moduleName.pascalCase}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${l10nKey}Label),
      child: AppDropdownField<$typeName>(
        initialSelection: selection,
        onSelected: onSelected,
        hintText: l10n.${l10nKey}Hint,
        menuEntries: _buildEntries(),
      ),
    );
  }
}
''';
}
