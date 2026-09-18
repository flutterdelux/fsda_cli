import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../enums/form_input_type.dart';
import '../../models/generation/input_typed_field.dart';

class UiFormService {
  const UiFormService();

  Future<({Map<String, List<int>> files, String uiYamlRaw})>
  rewriteFormArtifactsByFields({
    required String moduleName,
    required String featureName,
    required String sliceName,
    required List<InputTypedField> fields,
    required bool dialogMode,
    required Map<String, List<int>> files,
    String? initialType,
  }) async {
    final formPath = files.keys.firstWhere(
      (path) =>
          path.startsWith('ui/$sliceName/widgets/') &&
          path.endsWith('_form.dart'),
      orElse: () => '',
    );
    if (formPath.isEmpty) {
      throw const FormatException(
        'Unable to resolve generated form widget file.',
      );
    }

    final formParamFields = await _readFormParamFields(
      moduleName: moduleName,
      featureName: featureName,
      sliceName: sliceName,
    );
    final canResolveParamConstructor = formParamFields.isNotEmpty;

    final nextFiles = Map<String, List<int>>.from(files);
    nextFiles.removeWhere(
      (path, _) =>
          path.startsWith('ui/shared/widgets/') && path.endsWith('_field.dart'),
    );

    final normalizedInitialType = _normalizeInitialType(initialType);

    nextFiles[formPath] = utf8.encode(
      _buildDynamicFormWidget(
        moduleName: moduleName,
        featureName: featureName,
        sliceName: sliceName,
        fields: fields,
        paramFields: formParamFields,
        canResolveParamConstructor: canResolveParamConstructor,
        initialType: normalizedInitialType,
      ),
    );

    final uiYamlRaw = _buildDynamicFormYaml(
      featureName: featureName,
      sliceName: sliceName,
      dialogMode: dialogMode,
    );

    return (files: nextFiles, uiYamlRaw: uiYamlRaw);
  }

  Future<List<({String name, String type})>> _readFormParamFields({
    required String moduleName,
    required String featureName,
    required String sliceName,
  }) async {
    final paramPath = p.join(
      Directory.current.path,
      'modules',
      moduleName,
      'lib',
      'src',
      'features',
      featureName,
      'domain',
      'params',
      '${featureName.snakeCase}_${sliceName.snakeCase}_param.dart',
    );
    final paramFile = File(paramPath);
    if (!await paramFile.exists()) {
      return const <({String name, String type})>[];
    }

    final source = await paramFile.readAsString();
    final expectedClassName =
        '${featureName.pascalCase}${sliceName.pascalCase}Param';
    final constructorMatch =
        RegExp(
          r'const\s+factory\s+' +
              RegExp.escape(expectedClassName) +
              r'\s*\(([\s\S]*?)\)\s*=\s*_',
          dotAll: true,
        ).firstMatch(source) ??
        RegExp(
          r'const\s+factory\s+[A-Za-z_]\w*Param\s*\(([\s\S]*?)\)\s*=\s*_',
          dotAll: true,
        ).firstMatch(source);

    if (constructorMatch == null) {
      return const <({String name, String type})>[];
    }

    final constructorParams = constructorMatch.group(1) ?? '';
    final fields = <({String name, String type})>[];

    for (final paramMatch in RegExp(
      r'(?:required\s+)?([A-Za-z_][A-Za-z0-9_<>,? ]*)\s+([A-Za-z_]\w*)\s*(?:,|$|[}\]])',
      multiLine: true,
    ).allMatches(constructorParams)) {
      final fieldType = paramMatch.group(1)?.trim();
      final fieldName = paramMatch.group(2)?.trim();
      if (fieldType == null || fieldType.isEmpty) {
        continue;
      }
      if (fieldName == null || fieldName.isEmpty) {
        continue;
      }
      fields.add((name: fieldName, type: fieldType));
    }

    return fields;
  }

  String _buildDynamicFormWidget({
    required String moduleName,
    required String featureName,
    required String sliceName,
    required List<InputTypedField> fields,
    required List<({String name, String type})> paramFields,
    required bool canResolveParamConstructor,
    String? initialType,
  }) {
    final featureSnake = featureName.snakeCase;
    final sliceSnake = sliceName.snakeCase;
    final featurePascal = featureName.pascalCase;
    final slicePascal = sliceName.pascalCase;
    final modulePascal = moduleName.pascalCase;
    final featureCamel = featureName.camelCase;
    final formClass = '$featurePascal${slicePascal}Form';
    final formStateClass = '_$featurePascal${slicePascal}FormState';
    final paramClass = '$featurePascal${slicePascal}Param';
    final localizationsClass = '${modulePascal}Localizations';
    final resolvedInitialType = initialType ?? '';
    final hasInitialData = resolvedInitialType.isNotEmpty;

    final textFields = fields
        .where(_usesTextControllerForFormField)
        .toList(growable: false);
    final notifierFields = fields
        .where((field) => !_usesTextControllerForFormField(field))
        .toList(growable: false);

    final fieldImports = fields
        .map(
          (field) =>
              "import '../../shared/widgets/${featureSnake}_${field.name.snakeCase}_field.dart';",
        )
        .toSet()
        .join('\n');

    final valueTypeImports = _buildFormValueTypeImports(
      fields: fields,
      initialType: resolvedInitialType,
    );

    final extraWidgetFields = <String>[];
    final extraCtorParams = <String>[];

    for (final field in fields) {
      final fieldPascal = field.name.pascalCase;
      final typeName = field.typeWithoutNullability;

      switch (field.inputType) {
        case FormInputType.selector:
        case FormInputType.image:
          extraWidgetFields.add(
            '  final Future<$typeName?> Function(BuildContext context, $typeName? currentSelected)? onSelect$fieldPascal;',
          );
          extraCtorParams.add('    this.onSelect$fieldPascal,');
        case FormInputType.selectorList:
          extraWidgetFields.add(
            '  final Future<List<$typeName>?> Function(BuildContext context, List<$typeName> currentSelected)? onSelect$fieldPascal;',
          );
          extraCtorParams.add('    this.onSelect$fieldPascal,');
        case FormInputType.text:
        case FormInputType.textArea:
        case FormInputType.qty:
        case FormInputType.dropdown:
        case FormInputType.dropdownEnum:
        case FormInputType.switcher:
        case FormInputType.password:
          break;
      }
    }

    final controllerDeclarations = textFields
        .map(
          (field) =>
              '  late final TextEditingController _${field.name.camelCase}Controller;',
        )
        .join('\n');
    final notifierDeclarations = notifierFields
        .map(
          (field) =>
              '  late final ValueNotifier<${_resolveFormNotifierType(field)}> _${field.name.camelCase}Notifier;',
        )
        .join('\n');
    final fieldDeclarations = <String>[
      if (controllerDeclarations.isNotEmpty) controllerDeclarations,
      if (notifierDeclarations.isNotEmpty) notifierDeclarations,
    ].join('\n');

    final valueInfoByFieldName =
        <String, ({String variableName, bool nullable})>{};
    final inputValidation = StringBuffer();

    for (final field in fields) {
      final fieldName = field.name;
      final fieldCamel = fieldName.camelCase;
      final fieldPascal = fieldName.pascalCase;

      if (_usesTextControllerForFormField(field)) {
        final inputName = '${fieldCamel}Input';
        inputValidation.writeln(
          '    final $inputName = _${fieldCamel}Controller.text;',
        );

        final valueName = '${fieldCamel}Value';
        final valueExpression = _resolveTextFieldValueExpression(
          field: field,
          inputVariable: inputName,
        );
        inputValidation.writeln('    final $valueName = $valueExpression;');

        if (field.isRequired) {
          if (field.typeWithoutNullability == 'String') {
            inputValidation.writeln('    if ($inputName.isEmpty) {');
          } else {
            inputValidation.writeln('    if ($valueName == null) {');
          }
          inputValidation.writeln(
            '      widget.onListen(context, null, l10n.${featureCamel}Field${fieldPascal}InvalidEmpty);',
          );
          inputValidation.writeln('      return;');
          inputValidation.writeln('    }');
        }

        inputValidation.writeln();

        valueInfoByFieldName[fieldName.camelCase] = (
          variableName: valueName,
          nullable: _isTextValueNullable(field),
        );
        continue;
      }

      final valueName = '${fieldCamel}Value';
      inputValidation.writeln(
        '    final $valueName = _${fieldCamel}Notifier.value;',
      );

      if (field.isRequired) {
        if (field.inputType == FormInputType.selectorList) {
          inputValidation.writeln('    if ($valueName.isEmpty) {');
        } else if (field.inputType != FormInputType.switcher) {
          inputValidation.writeln('    if ($valueName == null) {');
        }

        if (field.inputType != FormInputType.switcher) {
          inputValidation.writeln(
            '      widget.onListen(context, null, l10n.${featureCamel}Field${fieldPascal}InvalidEmpty);',
          );
          inputValidation.writeln('      return;');
          inputValidation.writeln('    }');
        }
      }

      inputValidation.writeln();

      valueInfoByFieldName[fieldName.camelCase] = (
        variableName: valueName,
        nullable:
            field.inputType != FormInputType.switcher &&
            field.inputType != FormInputType.selectorList,
      );
    }

    final fieldByKey = <String, InputTypedField>{};
    for (final field in fields) {
      fieldByKey[field.name.toLowerCase()] = field;
      fieldByKey[field.name.snakeCase.toLowerCase()] = field;
      fieldByKey[field.name.camelCase.toLowerCase()] = field;
    }

    final paramAssignments = <String>[];
    for (final paramField in paramFields) {
      final paramName = paramField.name;
      final matchedField =
          fieldByKey[paramName.toLowerCase()] ??
          fieldByKey[paramName.snakeCase.toLowerCase()] ??
          fieldByKey[paramName.camelCase.toLowerCase()];

      late final String assignmentExpression;
      if (matchedField == null) {
        assignmentExpression = _defaultExpressionForParamType(paramField.type);
      } else {
        final valueInfo = valueInfoByFieldName[matchedField.name.camelCase];
        if (valueInfo == null) {
          assignmentExpression = _defaultExpressionForParamType(
            paramField.type,
          );
        } else {
          assignmentExpression = _adaptValueForParamType(
            valueInfo: valueInfo,
            paramType: paramField.type,
          );
        }
      }

      paramAssignments.add('      $paramName: $assignmentExpression,');
    }

    final initControllers = textFields
        .map((field) {
          final fieldCamel = field.name.camelCase;

          if (hasInitialData) {
            final initialTextExpression =
                _resolveInitialControllerTextExpression(field);
            return '    _${fieldCamel}Controller = TextEditingController(text: $initialTextExpression)..addListener(_onInputChanged);';
          }

          if (field.hasDefault) {
            final defaultExpression = _resolveFormFieldDefaultExpression(field);
            return '    _${fieldCamel}Controller = TextEditingController(text: $defaultExpression.toString())..addListener(_onInputChanged);';
          }

          return '    _${fieldCamel}Controller = TextEditingController()..addListener(_onInputChanged);';
        })
        .join('\n');

    final initNotifiers = notifierFields
        .map((field) {
          final fieldCamel = field.name.camelCase;
          final notifierType = _resolveFormNotifierType(field);
          final initialValueExpression = _resolveInitialNotifierValueExpression(
            field: field,
            hasInitialData: hasInitialData,
          );

          return '    _${fieldCamel}Notifier = ValueNotifier<$notifierType>($initialValueExpression)..addListener(_onInputChanged);';
        })
        .join('\n');

    final disposeControllers = textFields
        .map(
          (field) =>
              '    _${field.name.camelCase}Controller\n      ..removeListener(_onInputChanged)\n      ..dispose();',
        )
        .join('\n');

    final disposeNotifiers = notifierFields
        .map(
          (field) =>
              '    _${field.name.camelCase}Notifier\n      ..removeListener(_onInputChanged)\n      ..dispose();',
        )
        .join('\n');

    final fieldWidgets = <String>[];
    for (var i = 0; i < fields.length; i += 1) {
      final field = fields[i];
      final fieldName = field.name;
      final fieldCamel = fieldName.camelCase;
      final fieldPascal = fieldName.pascalCase;
      final widgetClass = '$featurePascal${fieldPascal}Field';

      switch (field.inputType) {
        case FormInputType.text:
        case FormInputType.textArea:
        case FormInputType.qty:
        case FormInputType.password:
          fieldWidgets.add(
            '        $widgetClass(controller: _${fieldCamel}Controller),',
          );
        case FormInputType.switcher:
          fieldWidgets.add('        ValueListenableBuilder<bool>(');
          fieldWidgets.add(
            '          valueListenable: _${fieldCamel}Notifier,',
          );
          fieldWidgets.add('          builder: (_, value, _) {');
          fieldWidgets.add('            return $widgetClass(');
          fieldWidgets.add('              value: value,');
          fieldWidgets.add('              onChanged: (next) {');
          fieldWidgets.add(
            '                _${fieldCamel}Notifier.value = next;',
          );
          fieldWidgets.add('              },');
          fieldWidgets.add('            );');
          fieldWidgets.add('          },');
          fieldWidgets.add('        ),');
        case FormInputType.dropdown:
          fieldWidgets.add(
            '        ValueListenableBuilder<${field.typeWithoutNullability}?>(valueListenable: _${fieldCamel}Notifier, builder: (_, value, _) {',
          );
          fieldWidgets.add('          return $widgetClass(');
          fieldWidgets.add('            selection: value,');
          fieldWidgets.add('            onSelected: (next) {');
          fieldWidgets.add(
            '              _${fieldCamel}Notifier.value = next;',
          );
          fieldWidgets.add('            },');
          fieldWidgets.add('          );');
          fieldWidgets.add('        }),');
        case FormInputType.dropdownEnum:
          fieldWidgets.add(
            '        ValueListenableBuilder<${field.typeWithoutNullability}?>(valueListenable: _${fieldCamel}Notifier, builder: (_, value, _) {',
          );
          fieldWidgets.add('          return $widgetClass(');
          fieldWidgets.add('            selection: value,');
          fieldWidgets.add('            onSelected: (next) {');
          fieldWidgets.add(
            '              _${fieldCamel}Notifier.value = next;',
          );
          fieldWidgets.add('            },');
          fieldWidgets.add('          );');
          fieldWidgets.add('        }),');
        case FormInputType.selector:
        case FormInputType.image:
          fieldWidgets.add(
            '        ValueListenableBuilder<${field.typeWithoutNullability}?>(valueListenable: _${fieldCamel}Notifier, builder: (_, value, _) {',
          );
          fieldWidgets.add('          return $widgetClass(');
          fieldWidgets.add('            selectedValue: value,');
          fieldWidgets.add(
            '            onClear: () => _${fieldCamel}Notifier.value = null,',
          );
          fieldWidgets.add('            onSelect: (currentSelected) async {');
          fieldWidgets.add(
            '              final result = await widget.onSelect$fieldPascal?.call(context, currentSelected);',
          );
          fieldWidgets.add(
            '              if (result != null && result != currentSelected) {',
          );
          fieldWidgets.add(
            '                _${fieldCamel}Notifier.value = result;',
          );
          fieldWidgets.add('              }');
          fieldWidgets.add('            },');
          fieldWidgets.add('          );');
          fieldWidgets.add('        }),');
        case FormInputType.selectorList:
          fieldWidgets.add(
            '        ValueListenableBuilder<List<${field.typeWithoutNullability}>>(valueListenable: _${fieldCamel}Notifier, builder: (_, value, _) {',
          );
          fieldWidgets.add('          return $widgetClass(');
          fieldWidgets.add('            selectedValues: value,');
          fieldWidgets.add(
            '            onClear: () => _${fieldCamel}Notifier.value = [],',
          );
          fieldWidgets.add('            onSelect: (currentSelected) async {');
          fieldWidgets.add(
            '              final result = await widget.onSelect$fieldPascal?.call(context, currentSelected);',
          );
          fieldWidgets.add(
            '              if (result != null && result != currentSelected) {',
          );
          fieldWidgets.add(
            '                _${fieldCamel}Notifier.value = result;',
          );
          fieldWidgets.add('              }');
          fieldWidgets.add('            },');
          fieldWidgets.add('          );');
          fieldWidgets.add('        }),');
      }

      if (i != fields.length - 1) {
        fieldWidgets.add('        AppGap.lg,');
      }
    }

    final widgetFieldsBlock = extraWidgetFields.isNotEmpty
        ? '${extraWidgetFields.join('\n')}\n'
        : '';
    final widgetConstructorBlock = extraCtorParams.isNotEmpty
        ? '${extraCtorParams.join('\n')}\n'
        : '';

    final initBlock = <String>[
      if (initControllers.isNotEmpty) initControllers,
      if (initNotifiers.isNotEmpty) initNotifiers,
      '    _onInputChanged();',
    ].join('\n');

    final disposeBlock = <String>[
      if (disposeControllers.isNotEmpty) disposeControllers,
      if (disposeNotifiers.isNotEmpty) disposeNotifiers,
    ].join('\n');

    final initialDataFieldBlock = hasInitialData
        ? '  final $resolvedInitialType initialData;\n'
        : '';
    final initialDataCtorBlock = hasInitialData
        ? '    required this.initialData,\n'
        : '';

    return '''import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/params/${featureSnake}_${sliceSnake}_param.dart';
$fieldImports
${valueTypeImports.isEmpty ? '' : '$valueTypeImports\n'}
import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class $formClass extends StatefulWidget {
  final void Function(
    BuildContext context,
    $paramClass? param,
    String? invalidMessage,
  )
  onListen;
$widgetFieldsBlock$initialDataFieldBlock  const $formClass({
    super.key,
    required this.onListen,
$widgetConstructorBlock$initialDataCtorBlock  });

  @override
  State<$formClass> createState() => $formStateClass();
}

class $formStateClass extends State<$formClass> {
$fieldDeclarations

  void _onInputChanged() {
    final l10n = $localizationsClass.of(context)!;

${inputValidation.toString().trimRight()}
${canResolveParamConstructor && paramAssignments.isNotEmpty ? '''    final param = $paramClass(
${paramAssignments.join('\n')}
    );''' : '''    // Keep form generation resilient when param constructor cannot be resolved.
    // Developer can map param manually later based on use case needs.
    final param = null;'''}
    widget.onListen(context, param, null);
  }

  @override
  void initState() {
    super.initState();
$initBlock
  }

  @override
  void dispose() {
$disposeBlock
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
${fieldWidgets.join('\n')}
      ],
    );
  }
}
''';
  }

  bool _usesTextControllerForFormField(InputTypedField field) {
    switch (field.inputType) {
      case FormInputType.text:
      case FormInputType.textArea:
      case FormInputType.qty:
      case FormInputType.password:
        return true;
      case FormInputType.selector:
      case FormInputType.selectorList:
      case FormInputType.dropdown:
      case FormInputType.dropdownEnum:
      case FormInputType.image:
      case FormInputType.switcher:
        return false;
    }
  }

  bool _isTextValueNullable(InputTypedField field) {
    if (!field.isNullable) {
      return field.typeWithoutNullability != 'String';
    }

    return true;
  }

  String _resolveTextFieldValueExpression({
    required InputTypedField field,
    required String inputVariable,
  }) {
    final normalizedType = field.typeWithoutNullability;

    switch (normalizedType) {
      case 'String':
        return field.isNullable
            ? '$inputVariable.isEmpty ? null : $inputVariable'
            : inputVariable;
      case 'int':
        return '$inputVariable.isEmpty ? null : int.tryParse($inputVariable)';
      case 'double':
        return '$inputVariable.isEmpty ? null : double.tryParse($inputVariable)';
      case 'num':
        return '$inputVariable.isEmpty ? null : num.tryParse($inputVariable)';
      case 'BigInt':
        return '$inputVariable.isEmpty ? null : BigInt.tryParse($inputVariable)';
      case 'bool':
        final lowerVar = '${inputVariable}Lower';
        return '$inputVariable.isEmpty ? null : (() { final $lowerVar = $inputVariable.toLowerCase(); return $lowerVar == "true" ? true : ($lowerVar == "false" ? false : null); })()';
      default:
        return inputVariable;
    }
  }

  String _resolveFormNotifierType(InputTypedField field) {
    final normalizedType = field.typeWithoutNullability;

    switch (field.inputType) {
      case FormInputType.selectorList:
        return 'List<$normalizedType>';
      case FormInputType.switcher:
        return 'bool';
      case FormInputType.text:
      case FormInputType.textArea:
      case FormInputType.qty:
      case FormInputType.selector:
      case FormInputType.dropdown:
      case FormInputType.dropdownEnum:
      case FormInputType.image:
      case FormInputType.password:
        return '$normalizedType?';
    }
  }

  String _adaptValueForParamType({
    required ({String variableName, bool nullable}) valueInfo,
    required String paramType,
  }) {
    if (!_isNullableParamType(paramType) && valueInfo.nullable) {
      return '${valueInfo.variableName}!';
    }

    return valueInfo.variableName;
  }

  String _resolveFormFieldDefaultExpression(InputTypedField field) {
    final rawDefault = field.defaultValue?.trim();
    if (rawDefault == null || rawDefault.isEmpty) {
      return 'null';
    }

    final normalizedType = field.typeWithoutNullability;
    if (normalizedType == 'String') {
      final isSingleQuoted =
          rawDefault.startsWith("'") && rawDefault.endsWith("'");
      final isDoubleQuoted =
          rawDefault.startsWith('"') && rawDefault.endsWith('"');
      if (isSingleQuoted || isDoubleQuoted) {
        return rawDefault;
      }

      final escapedValue = rawDefault
          .replaceAll(r'\\', r'\\\\')
          .replaceAll("'", r"\\'");
      return "'$escapedValue'";
    }

    return rawDefault;
  }

  String _resolveInitialNotifierValueExpression({
    required InputTypedField field,
    required bool hasInitialData,
  }) {
    final propertyAccess = 'widget.initialData.${field.name.camelCase}';

    if (field.inputType == FormInputType.selectorList) {
      if (hasInitialData) {
        if (field.isNullable) {
          return '(($propertyAccess ?? const <${field.typeWithoutNullability}>[]) as List<${field.typeWithoutNullability}>).toList()';
        }
        return '($propertyAccess as List<${field.typeWithoutNullability}>).toList()';
      }

      final defaultExpression = _resolveFormFieldDefaultExpression(field);
      if (defaultExpression == 'null') {
        return 'const <${field.typeWithoutNullability}>[]';
      }
      return '($defaultExpression as List<${field.typeWithoutNullability}>).toList()';
    }

    if (field.inputType == FormInputType.switcher) {
      if (hasInitialData) {
        return field.isNullable ? '$propertyAccess ?? false' : propertyAccess;
      }

      final defaultExpression = _resolveFormFieldDefaultExpression(field);
      if (defaultExpression == 'null') {
        return 'false';
      }
      return defaultExpression;
    }

    if (hasInitialData) {
      if (!field.isNullable) {
        return propertyAccess;
      }

      final defaultExpression = _resolveFormFieldDefaultExpression(field);
      if (defaultExpression == 'null') {
        return propertyAccess;
      }
      return '$propertyAccess ?? $defaultExpression';
    }

    final defaultExpression = _resolveFormFieldDefaultExpression(field);
    return defaultExpression;
  }

  bool _isNullableParamType(String type) {
    return type.replaceAll(' ', '').endsWith('?');
  }

  String _defaultExpressionForParamType(String paramType) {
    if (_isNullableParamType(paramType)) {
      return 'null';
    }

    final compact = paramType.replaceAll(' ', '');
    final normalizedType = compact.endsWith('?')
        ? compact.substring(0, compact.length - 1)
        : compact;

    switch (normalizedType) {
      case 'String':
        return "''";
      case 'int':
        return '0';
      case 'double':
        return '0.0';
      case 'bool':
        return 'false';
      default:
        if (normalizedType.startsWith('List<')) {
          return 'const []';
        }
        if (normalizedType.startsWith('Map<')) {
          return 'const {}';
        }
        if (normalizedType.startsWith('Set<')) {
          return '<dynamic>{}';
        }
        return "''";
    }
  }

  String _buildDynamicFormYaml({
    required String featureName,
    required String sliceName,
    required bool dialogMode,
  }) {
    final featureCamel = featureName.camelCase;
    final featurePascal = featureName.pascalCase;
    final featureSnake = featureName.snakeCase;
    final slicePascal = sliceName.pascalCase;
    final sliceSnake = sliceName.snakeCase;
    final featureTitle = featureName.titleCase;
    final sliceTitle = sliceName.titleCase;
    final featureSentence = featureName.replaceAll('_', ' ');
    final sliceSentence = sliceName.replaceAll('_', ' ');

    final failureKey = 'failure${featurePascal}FormInvalid';
    final titleKey = '$featureCamel${slicePascal}Title';
    final descriptionKey = '$featureCamel${slicePascal}Description';
    final actionKey = '$featureCamel${slicePascal}Action';
    final successKey = '$featureCamel${slicePascal}Success';
    final featureSlice = '${featureSnake}_$sliceSnake';
    final logicCubitExport =
        "export 'logic/$sliceSnake/${featureSlice}_form_cubit.dart';";
    final logicStateExport =
        "export 'logic/$sliceSnake/${featureSlice}_form_state.dart';";

    final arbLines = <String>[
      '"$failureKey": "Please fill in all required fields correctly",',
      '"$titleKey": "$sliceTitle $featureTitle",',
      if (dialogMode)
        '"$descriptionKey": "Please complete $featureSentence $sliceSentence data",',
      '"$actionKey": "$sliceTitle",',
      '"$successKey": "$featureTitle created successfully",',
    ];

    final uiExports = <String>[
      if (!dialogMode)
        "export 'ui/$sliceSnake/views/${featureSlice}_view.dart';",
      if (dialogMode)
        "export 'ui/$sliceSnake/widgets/${featureSlice}_dialog.dart';",
      "export 'ui/$sliceSnake/widgets/${featureSlice}_button.dart';",
      "export 'ui/$sliceSnake/widgets/${featureSlice}_form.dart';",
    ];

    final arbBlock = arbLines.join('\n  ');
    final uiExportBlock = uiExports.join('\n    ');

    return '''arb: |
  $arbBlock

export:
  logic: |
    $logicCubitExport
    $logicStateExport
  ui: |
    $uiExportBlock

post_hooks:
  - flutter gen-l10n
  - dart run build_runner build --delete-conflicting-outputs --force-jit
''';
  }

  String _buildFormValueTypeImports({
    required List<InputTypedField> fields,
    required String initialType,
  }) {
    final imports = <String>{};
    final referencedTypes = <String>{};

    for (final field in fields) {
      referencedTypes.addAll(_extractTypeTokens(field.typeWithoutNullability));
    }

    if (initialType.isNotEmpty) {
      referencedTypes.add(initialType.replaceAll(' ', '').replaceAll('?', ''));
    }

    for (final type in referencedTypes) {
      if (_isPrimitiveTypeToken(type) || _isCollectionTypeToken(type)) {
        continue;
      }

      if (type == 'NetworkFile') {
        imports.add("import 'package:app_core/app_core.dart';");
        continue;
      }

      if (type.endsWith('Entity')) {
        imports.add(
          "import '../../../domain/entities/${_resolveEntityFileName(type)}.dart';",
        );
        continue;
      }

      if (type.endsWith('Dto')) {
        imports.add(
          "import '../../../data/dtos/${_resolveDtoFileName(type)}.dart';",
        );
        continue;
      }

      imports.add("import '../../../domain/enums/${type.snakeCase}.dart';");
    }

    final ordered = imports.toList(growable: false)..sort();
    return ordered.join('\n');
  }

  Set<String> _extractTypeTokens(String typeExpression) {
    final compact = typeExpression.replaceAll(' ', '').replaceAll('?', '');
    final matches = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(compact);

    final tokens = <String>{};
    for (final match in matches) {
      final token = match.group(0);
      if (token == null || token.isEmpty) {
        continue;
      }
      tokens.add(token);
    }

    return tokens;
  }

  bool _isCollectionTypeToken(String token) {
    switch (token) {
      case 'List':
      case 'Map':
      case 'Set':
      case 'Iterable':
        return true;
      default:
        return false;
    }
  }

  bool _isPrimitiveTypeToken(String token) {
    switch (token) {
      case 'String':
      case 'int':
      case 'double':
      case 'num':
      case 'bool':
      case 'dynamic':
      case 'Object':
      case 'DateTime':
      case 'Duration':
      case 'BigInt':
        return true;
      default:
        return false;
    }
  }

  String _resolveEntityFileName(String entityType) {
    final normalized = entityType.replaceAll(' ', '').replaceAll('?', '');
    final baseName = normalized.endsWith('Entity')
        ? normalized.substring(0, normalized.length - 'Entity'.length)
        : normalized;
    return '${baseName.snakeCase}_entity';
  }

  String _resolveDtoFileName(String dtoType) {
    final normalized = dtoType.replaceAll(' ', '').replaceAll('?', '');
    final baseName = normalized.endsWith('Dto')
        ? normalized.substring(0, normalized.length - 'Dto'.length)
        : normalized;
    return '${baseName.snakeCase}_dto';
  }

  String? _normalizeInitialType(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.replaceAll(' ', '').trim();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String _resolveInitialControllerTextExpression(InputTypedField field) {
    final propertyAccess = 'widget.initialData.${field.name.camelCase}';
    final normalizedType = field.typeWithoutNullability;

    if (normalizedType == 'String') {
      if (field.isNullable) {
        return '$propertyAccess ?? ${_resolveDefaultControllerTextLiteral(field)}';
      }
      return propertyAccess;
    }

    if (field.isNullable) {
      return '$propertyAccess?.toString() ?? ${_resolveDefaultControllerTextLiteral(field)}';
    }

    return '$propertyAccess.toString()';
  }

  String _resolveDefaultControllerTextLiteral(InputTypedField field) {
    final rawDefault = field.defaultValue?.trim();
    if (rawDefault == null || rawDefault.isEmpty) {
      return "''";
    }

    if (field.typeWithoutNullability == 'String') {
      if ((rawDefault.startsWith("'") && rawDefault.endsWith("'")) ||
          (rawDefault.startsWith('"') && rawDefault.endsWith('"'))) {
        return rawDefault;
      }

      final escaped = rawDefault
          .replaceAll(r'\\', r'\\\\')
          .replaceAll("'", r"\\'");
      return "'$escaped'";
    }

    final escaped = rawDefault
        .replaceAll(r'\\', r'\\\\')
        .replaceAll("'", r"\\'");
    return "'$escaped'";
  }
}
