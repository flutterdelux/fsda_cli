import 'package:mason/mason.dart';

import '../../../enums/input_code.dart';
import '../../../models/generation/typed_prop.dart';

class InputArbEntryBuilderService {
  const InputArbEntryBuilderService();

  Map<String, dynamic> buildEntriesByInputCode({
    required String featureName,
    required List<String> fields,
    required InputCode inputCode,
  }) {
    final entries = <String, dynamic>{};
    final featureCamel = featureName.camelCase;
    final featureSentence = featureName.replaceAll('_', ' ');

    for (final field in fields) {
      final fieldPascal = field.pascalCase;
      final fieldTitle = field.titleCase;
      final fieldSentence = field.replaceAll('_', ' ');
      final key = '${featureCamel}Field$fieldPascal';

      switch (inputCode) {
        case InputCode.text:
          entries['${key}Label'] = fieldTitle;
          entries['${key}Hint'] = 'Enter $featureSentence $fieldSentence...';
          entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';
        case InputCode.dropdown:
        case InputCode.dropdownEnum:
          entries['${key}Label'] = fieldTitle;
          entries['${key}Hint'] = 'Select $featureSentence $fieldSentence...';
          entries['${key}InvalidEmpty'] = '$fieldTitle must be selected';
        case InputCode.password:
          entries['${key}Hint'] = 'Enter $fieldSentence...';
          entries['${key}InvalidEmpty'] = '$fieldTitle cannot be empty';
      }
    }

    return entries;
  }

  Map<String, dynamic> buildEnumDropdownEntries({
    required String featureName,
    required List<TypedProp> fields,
  }) {
    final entries = <String, dynamic>{};
    final featureCamel = featureName.camelCase;
    final featureSentence = featureName.replaceAll('_', ' ');

    for (final item in fields) {
      final fieldPascal = item.name.pascalCase;
      final fieldTitle = item.name.titleCase;
      final fieldSentence = item.name.replaceAll('_', ' ');
      final key = '${featureCamel}Field$fieldPascal';

      entries['${key}Label'] = fieldTitle;
      entries['${key}Hint'] = 'Select $featureSentence $fieldSentence...';
      entries['${key}InvalidEmpty'] = '$fieldTitle must be selected';
    }

    return entries;
  }

  Map<String, dynamic> buildDropdownEntries({
    required String featureName,
    required List<TypedProp> fields,
  }) {
    final entries = <String, dynamic>{};
    final featureCamel = featureName.camelCase;
    final featureSentence = featureName.replaceAll('_', ' ');

    for (final item in fields) {
      final fieldPascal = item.name.pascalCase;
      final fieldTitle = item.name.titleCase;
      final fieldSentence = item.name.replaceAll('_', ' ');
      final key = '${featureCamel}Field$fieldPascal';
      entries['${key}Label'] = fieldTitle;
      entries['${key}Hint'] = 'Select $featureSentence $fieldSentence...';
      entries['${key}InvalidEmpty'] = '$fieldTitle must be selected';
    }

    return entries;
  }

  Map<String, dynamic> buildSwitchEntries({
    required String featureName,
    required List<String> fields,
  }) {
    final entries = <String, dynamic>{};
    final featureCamel = featureName.camelCase;
    final featureSentence = featureName.replaceAll('_', ' ');

    for (final field in fields) {
      final fieldPascal = field.pascalCase;
      final fieldTitle = field.titleCase;
      final fieldSentence = field.replaceAll('_', ' ');
      final key = '${featureCamel}Field$fieldPascal';

      entries['${key}Label'] = fieldTitle;
      entries['${key}Hint'] = 'Toggle $featureSentence $fieldSentence';
    }

    return entries;
  }
}
