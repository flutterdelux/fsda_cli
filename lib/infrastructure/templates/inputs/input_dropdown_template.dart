import '../../../domain/params/input_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputDropdownTemplate {
  static String build(InputParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final className = '$featurePascal${fieldPascal}Field';
    final typeName = input.dataType ?? '';
    final selectionType = typeName.endsWith('?') ? typeName : '$typeName?';

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';

class $className extends StatelessWidget {
  final List<$typeName> items;
  final ValueChanged<$typeName?>? onSelected;
  final $selectionType selection;
  final String Function($typeName item)? itemLabelBuilder;

  const $className({
    super.key,
    this.items = const [],
    this.onSelected,
    this.selection,
    this.itemLabelBuilder,
  });

  List<DropdownMenuEntry<$typeName>> _buildEntries() {
    return items
        .map((item) => DropdownMenuEntry<$typeName>(
              value: item,
              label: itemLabelBuilder?.call(item) ?? item.toString(),
            ))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ${input.moduleName.pascalCase}Localizations.of(context)!;
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
