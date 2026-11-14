import '../../../domain/params/inputs/input_dropdown_enum_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class InputDropdownEnumTemplate {
  static String build(InputDropdownEnumParam input) {
    final featurePascal = input.featureName.pascalCase;
    final fieldPascal = input.field.pascalCase;
    final l10nKey = '${input.featureName.camelCase}Field$fieldPascal';
    final className = '$featurePascal${fieldPascal}Field';
    final enumType = input.type;
    final enumTypeSnake = enumType.snakeCase;

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${input.moduleName}_localizations.dart';
import '../extensions/${enumTypeSnake}_x.dart';

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
    final l10n = ${input.moduleName.pascalCase}Localizations.of(context)!;
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

  static Map<String, dynamic> buildArbEntries(InputDropdownEnumParam input) {
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
