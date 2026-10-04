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
  final normalizedType = typeName.replaceAll(' ', '').replaceAll('?', '');
  final valueImport = _resolveTypeImport(normalizedType);

  return '''${valueImport.isEmpty ? '' : "$valueImport\n"}import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

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

String _resolveTypeImport(String typeName) {
  const primitiveTypes = <String>{
    'String',
    'int',
    'double',
    'num',
    'bool',
    'dynamic',
    'Object',
    'DateTime',
    'Duration',
    'BigInt',
  };

  if (primitiveTypes.contains(typeName)) {
    return '';
  }

  if (typeName == 'NetworkFile') {
    return "import 'package:app_core/app_core.dart';";
  }

  if (typeName.endsWith('Entity')) {
    return "import '../../../domain/entities/${typeName.snakeCase}.dart';";
  }

  if (typeName.endsWith('Dto')) {
    return "import '../../../data/dtos/${typeName.snakeCase}.dart';";
  }

  return "import '../../../domain/enums/${typeName.snakeCase}.dart';";
}
