import 'package:args/command_runner.dart';

import '../../constants/cli_rules.dart';
import '../../enums/form_input_type.dart';
import '../../enums/ui_code.dart';
import '../../models/generation/input_typed_field.dart';
import '../../services/parsing/input_typed_field_parser_service.dart';
import 'ui_base_command.dart';

class UiFormDialogCommand extends UiBaseCommand {
  final InputTypedFieldParserService typedFieldParser;
  final _trailingFieldTokens = <String>[];

  UiFormDialogCommand({
    required super.uiGenerator,
    required super.workspaceService,
    required super.operations,
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
        'type',
        help:
            'Required full snake_case data type name (for example manual_payment_method_entity).',
      )
      ..addFlag(
        'initial',
        negatable: false,
        help:
            'Include initialData of the same type as --type for edit/update forms.',
      );
  }

  @override
  UiCode get uiTemplate => UiCode.formDialog;

  @override
  final String name = 'ui-form-dialog';

  @override
  final String description =
      'Generate Form Dialog UI template and inject form-level ARB/export manifest (shared input fields are generated via input-* commands).';

  @override
  String get invocation =>
      'fsda ui-form-dialog <slice> -f <feature> -m <module> --fields "<input_type:value_type:field_name,...>" --type <data_type> [--initial] [--strict] [--hook-disabled]';

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
  String resolveFormDataType() {
    final rawType = (argResults?['type'] as String?)?.trim() ?? '';
    const supportedSuffixes = <String>{'_entity', '_dto', '_param', '_request'};
    final nameRegExp = RegExp(CliRules.artifactNamePattern);

    if (!nameRegExp.hasMatch(rawType) ||
        !supportedSuffixes.any(rawType.endsWith)) {
      throw UsageException(
        'Invalid data type "$rawType". Use a full snake_case artifact name ending in _entity, _dto, _param, or _request (for example manual_payment_method_entity).',
        usage,
      );
    }

    return rawType;
  }

  @override
  bool get initializeFormData => argResults?['initial'] as bool? ?? false;

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
        final typeRegExp = RegExp(CliRules.modelTypePattern);
        if (!typeRegExp.hasMatch(type) || !type.endsWith('Entity')) {
          throw UsageException(
            'Field "${field.name}" with input_type ${field.inputType.code} must use PascalCase Entity type (for example ProductCategoryEntity).',
            usage,
          );
        }
        return;
      case FormInputType.dropdown:
        final typeRegExp = RegExp(CliRules.modelTypePattern);
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

        final typeRegExp = RegExp(CliRules.modelTypePattern);
        if (!typeRegExp.hasMatch(type) || !type.endsWith('Entity')) {
          throw UsageException(
            'Field "${field.name}" with input_type image must use NetworkFile or PascalCase Entity type (for example ProductImageEntity).',
            usage,
          );
        }
        return;
      case FormInputType.dropdownEnum:
        final typeRegExp = RegExp(CliRules.modelTypePattern);
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
