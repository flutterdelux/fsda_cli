import 'package:args/command_runner.dart';

import '../../constants/cli_rules.dart';
import '../../enums/form_input_type.dart';
import '../../enums/ui_code.dart';
import '../../models/generation/input_typed_field.dart';
import '../../services/parsing/input_typed_field_parser_service.dart';
import 'ui_base_command.dart';

class UiFormCommand extends UiBaseCommand {
  final InputTypedFieldParserService typedFieldParser;
  final _trailingFieldTokens = <String>[];

  UiFormCommand({
    required super.uiGenerator,
    required super.workspaceService,
    InputTypedFieldParserService? typedFieldParser,
  }) : typedFieldParser =
           typedFieldParser ?? const InputTypedFieldParserService() {
    argParser
      ..addMultiOption(
        'fields',
        help:
            'Required typed form fields with syntax input_type:value_type:field_name. Supported input_type: text, number, selector, selector_list, text_area, qty, dropdown, dropdown_enum, image, switch, password. Repeat --fields or pass comma-separated values.',
      )
      ..addOption(
        'initial',
        help:
            'Optional entity type for update form prefill (for example CategoryEntity).',
      );
  }

  @override
  UiCode get uiTemplate => UiCode.form;

  @override
  final String name = 'ui-form';

  @override
  final String description =
      'Generate Form UI template and inject form-level ARB/export manifest (shared input fields are generated via input-* commands).';

  @override
  String get invocation =>
      'fsda ui-form <slice> -f <feature> -m <module> --fields "<input_type:value_type:field_name,...>" [--initial <entity_type>] [--strict] [--hook-disabled]';

  @override
  void validateTrailingArgs(List<String> trailingArgs) {
    _trailingFieldTokens.clear();

    if (trailingArgs.isEmpty) {
      return;
    }

    for (final token in trailingArgs) {
      final normalizedToken = token.trim();
      if (normalizedToken.isEmpty) {
        continue;
      }

      final normalizedValue = normalizedToken
          .replaceFirst(RegExp(r'^,+'), '')
          .replaceFirst(RegExp(r',+$'), '')
          .trim();

      if (normalizedValue.isNotEmpty) {
        _trailingFieldTokens.add(normalizedValue);
      }
    }
  }

  @override
  List<InputTypedField> resolveFormInputFields() {
    final optionValues =
        argResults?['fields'] as List<String>? ?? const <String>[];

    try {
      final fields = typedFieldParser.parse(
        optionValues: optionValues,
        trailingValues: _trailingFieldTokens,
      );
      final fieldNameRegExp = RegExp(CliRules.sliceNamePattern);
      for (final field in fields) {
        if (!fieldNameRegExp.hasMatch(field.name)) {
          throw UsageException(
            'Invalid field name "${field.name}".\n${CliRules.sliceNameRule}',
            usage,
          );
        }

        _validateFieldTypeCompatibility(field);
      }

      return fields;
    } on FormatException catch (e) {
      throw UsageException(e.message.replaceAll('--props', '--fields'), usage);
    }
  }

  @override
  String? resolveInitialType() {
    final rawInitialType = (argResults?['initial'] as String?)?.trim();
    if (rawInitialType == null || rawInitialType.isEmpty) {
      return null;
    }

    final normalizedType = rawInitialType
        .replaceAll(' ', '')
        .replaceAll('?', '');
    final typeRegExp = RegExp(CliRules.modelPrefixPattern);

    if (!typeRegExp.hasMatch(normalizedType) ||
        !normalizedType.endsWith('Entity')) {
      throw UsageException(
        'Invalid initial type "$rawInitialType". Use PascalCase entity type, for example CategoryEntity.',
        usage,
      );
    }

    return normalizedType;
  }

  void _validateFieldTypeCompatibility(InputTypedField field) {
    final type = field.typeWithoutNullability;
    const numericTypes = <String>{'int', 'double', 'num', 'BigInt'};

    switch (field.inputType) {
      case FormInputType.switcher:
        if (type != 'bool') {
          throw UsageException(
            'Field "${field.name}" with input_type switch must use bool type.',
            usage,
          );
        }
        return;
      case FormInputType.qty:
        if (type != 'int') {
          throw UsageException(
            'Field "${field.name}" with input_type qty must use int type.',
            usage,
          );
        }
        return;
      case FormInputType.number:
        if (!numericTypes.contains(type)) {
          throw UsageException(
            'Field "${field.name}" with input_type number must use numeric type: int, double, num, or BigInt.',
            usage,
          );
        }
        return;
      case FormInputType.selector:
      case FormInputType.selectorList:
        final typeRegExp = RegExp(CliRules.modelPrefixPattern);
        if (!typeRegExp.hasMatch(type) || !type.endsWith('Entity')) {
          throw UsageException(
            'Field "${field.name}" with input_type ${field.inputType.code} must use PascalCase Entity type (for example ProductCategoryEntity).',
            usage,
          );
        }
        return;
      case FormInputType.dropdown:
        final typeRegExp = RegExp(CliRules.modelPrefixPattern);
        if (!typeRegExp.hasMatch(type) || !type.endsWith('Entity')) {
          throw UsageException(
            'Field "${field.name}" with input_type dropdown must use PascalCase Entity type (for example ProductCategoryEntity).',
            usage,
          );
        }
        return;
      case FormInputType.image:
        if (type == 'NetworkFile') {
          return;
        }

        final typeRegExp = RegExp(CliRules.modelPrefixPattern);
        if (!typeRegExp.hasMatch(type) || !type.endsWith('Entity')) {
          throw UsageException(
            'Field "${field.name}" with input_type image must use NetworkFile or PascalCase Entity type (for example ProductImageEntity).',
            usage,
          );
        }
        return;
      case FormInputType.dropdownEnum:
        final typeRegExp = RegExp(CliRules.modelPrefixPattern);
        if (!typeRegExp.hasMatch(type)) {
          throw UsageException(
            'Field "${field.name}" with input_type dropdown_enum must use PascalCase enum type (for example ProductStatus).',
            usage,
          );
        }
        return;
      case FormInputType.text:
      case FormInputType.textArea:
      case FormInputType.password:
        return;
    }
  }
}
