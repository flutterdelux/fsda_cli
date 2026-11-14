import '../../../domain/models/form_field_model.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class UiComposeFieldTemplate {
  static String prop(FormFieldModel formField) {
    final valueType = formField.valueType.replaceAll('?', '');
    final fieldPascal = formField.fieldName.pascalCase;
    return switch (formField.inputType) {
      .selector || .selectorList || .image =>
        '''
  final Future<$valueType?> Function(
    BuildContext context,
    $valueType? currentSelected,
  )?
  onSelect$fieldPascal;
''',
      _ => '',
    };
  }

  static String param(FormFieldModel formField) {
    final fieldPascal = formField.fieldName.pascalCase;
    return switch (formField.inputType) {
      .selector || .selectorList || .image => '    this.onSelect$fieldPascal,',
      _ => '',
    };
  }

  static String variable(FormFieldModel formField) {
    final fieldCamel = formField.fieldName.camelCase;
    return switch (formField.inputType) {
      .dropdown ||
      .dropdownEnum ||
      .image ||
      .selector ||
      .selectorList ||
      .swich =>
        "  late final ValueNotifier<${formField.valueType}> _${fieldCamel}Notifier;",
      .number || .password || .qty || .text || .textArea =>
        "  late final TextEditingController _${fieldCamel}Controller;",
    };
  }

  static String initState({
    required FormFieldModel formField,
    required bool hasInitial,
  }) {
    final valueType = formField.valueType;
    final fieldCamel = formField.fieldName.camelCase;
    final initialValue =
        formField.defaultValue ??
        (hasInitial ? 'widget.initialData.$fieldCamel' : null);

    if (initialValue != null) {
      return switch (formField.inputType) {
        .dropdown ||
        .dropdownEnum ||
        .image ||
        .selector ||
        .selectorList ||
        .swich =>
          '''
    _${fieldCamel}Notifier = ValueNotifier<$valueType>($initialValue)
      ..addListener(_onInputChanged);
''',
        .number || .qty || .password || .text || .textArea =>
          '''
    _${fieldCamel}Controller = TextEditingController(text: $initialValue)
      ..addListener(_onInputChanged);
''',
      };
    }

    return switch (formField.inputType) {
      .dropdown ||
      .dropdownEnum ||
      .image ||
      .selector ||
      .selectorList ||
      .swich =>
        '''
    _${fieldCamel}Notifier = ValueNotifier<$valueType?>(null)
      ..addListener(_onInputChanged);
''',
      .number || .qty || .password || .text || .textArea =>
        '''
    _${fieldCamel}Controller = TextEditingController()
      ..addListener(_onInputChanged);
''',
    };
  }

  static String dispose(FormFieldModel formField) {
    final fieldCamel = formField.fieldName.camelCase;
    return switch (formField.inputType) {
      .dropdown ||
      .dropdownEnum ||
      .image ||
      .selector ||
      .selectorList ||
      .swich =>
        '''
    _${fieldCamel}Notifier
      ..removeListener(_onInputChanged)
      ..dispose();
''',
      .number || .qty || .password || .text || .textArea =>
        '''
    _${fieldCamel}Controller
      ..removeListener(_onInputChanged)
      ..dispose();    
''',
    };
  }

  static String validation({
    required FormFieldModel formField,
    required String feature,
    required bool hasInitial,
  }) {
    final valueType = formField.valueType;
    final fieldCamel = formField.fieldName.camelCase;
    final fieldPascal = formField.fieldName.pascalCase;
    final hasDefault = formField.defaultValue != null || hasInitial;
    return switch (formField.inputType) {
      .dropdown ||
      .dropdownEnum ||
      .image ||
      .selector ||
      .selectorList ||
      .swich => [
        '    final $fieldCamel = _${fieldCamel}Notifier.value;',
        if (!hasDefault)
          '''
    if ($fieldCamel == null) {
      widget.onListen(context, null, l10n.${feature.camelCase}Field${fieldPascal}InvalidEmpty);
      return;
    }
'''
              .trim(),
      ].join('\n'),
      .password || .text || .textArea =>
        '''
    final $fieldCamel = _${fieldCamel}Controller.text;
    if ($fieldCamel.isEmpty) {
      widget.onListen(context, null, l10n.${feature.camelCase}Field${fieldPascal}InvalidEmpty);
      return;
    }
''',
      .number || .qty =>
        '''
    final ${fieldCamel}String = _${fieldCamel}Controller.text;
    if (${fieldCamel}Str.isEmpty) {
      widget.onListen(context, null, l10n.${feature.camelCase}Field${fieldPascal}InvalidEmpty);
      return;
    }
    final $fieldCamel = $valueType.tryParse($fieldCamel);
    if ($fieldCamel == null) {
      widget.onListen(context, null, l10n.${feature.camelCase}Field${fieldPascal}InvalidFormat);
      return;
    }
''',
    };
  }

  static String widget({
    required FormFieldModel formField,
    required String feature,
  }) {
    final valueType = formField.valueType;
    final fieldCamel = formField.fieldName.camelCase;
    final fieldPascal = formField.fieldName.pascalCase;
    final featurePascal = feature.pascalCase;
    return switch (formField.inputType) {
      .selector || .selectorList || .image =>
        '''
        ValueListenableBuilder<$valueType>(
          valueListenable: _${fieldCamel}Notifier,
          builder: (_, currentValue, _) {
            return $featurePascal${fieldPascal}Field(
              selectedValue: currentValue,
              onClear: () => _${fieldCamel}Notifier.value = null,
              onSelect: (currentSelected) async {
                final newValue = await widget.onSelect$fieldPascal?.call(
                  context,
                  currentSelected,
                );
                if (newValue != null && newValue != currentSelected) {
                  _${fieldCamel}Notifier.value = newValue;
                }
              },
            );
          },
        ),
''',
      .dropdown =>
        '''
        ValueListenableBuilder(
          valueListenable: _${fieldCamel}Notifier,
          builder: (_, currentValue, _) {
            return $featurePascal${fieldPascal}Field(
              items: [],
              selection: currentValue,
              onSelected: (newValue) {
                if (newValue == null) return;
                _${fieldCamel}Notifier.value = newValue;                
              },
              itemLabelBuilder: ($valueType item) {
                return item.toString();
              },
            );
          },
        ),
''',
      .dropdownEnum =>
        '''
        ValueListenableBuilder<$valueType>(
          valueListenable: _${fieldCamel}Notifier,
          builder: (_, currentValue, _) {
            return $featurePascal${fieldPascal}Field(
              selection: currentValue,
              onSelected: (newValue) {
                if (newValue == null) return;
                _${fieldCamel}Notifier.value = newValue;
              },
            );
          },
        ),
''',

      .swich =>
        '''
        ValueListenableBuilder<$valueType>(
          valueListenable: _${fieldCamel}Notifier,
          builder: (_, currentValue, _) {
            return $featurePascal${fieldPascal}Field(
              value: currentValue,
              onChanged: (newValue) {
                _${fieldCamel}Notifier.value = newValue;
              },
            );
          },
        ),
''',
      .password || .text || .textArea || .number || .qty =>
        '''
        $featurePascal${fieldPascal}Field(controller: _${fieldCamel}Controller),
''',
    };
  }
}
