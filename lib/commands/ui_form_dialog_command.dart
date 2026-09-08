import 'dart:collection';

import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiFormDialogCommand extends UiBaseCommand {
  final _trailingFieldTokens = <String>[];

  UiFormDialogCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService) {
    argParser.addMultiOption(
      'fields',
      help:
          'Required form field names. Repeat --fields or pass comma-separated values.',
    );
  }

  @override
  UiCode get uiTemplate => UiCode.formDialog;

  @override
  final String name = 'ui-form-dialog';

  @override
  final String description =
      'Generate Form Dialog UI template and inject its ARB/export manifest.';

  @override
  String get invocation =>
      'fsda ui-form-dialog <slice> -f <feature> -m <module> --fields <field_1,field_2,...> [--strict]';

  @override
  void validateTrailingArgs(List<String> trailingArgs) {
    if (trailingArgs.isEmpty) {
      return;
    }

    final fieldNameRegExp = RegExp(CliRules.sliceNamePattern);
    for (final token in trailingArgs) {
      final normalizedToken = token.trim();
      if (normalizedToken.isEmpty) {
        continue;
      }

      final normalizedField = normalizedToken.endsWith(',')
          ? normalizedToken.substring(0, normalizedToken.length - 1).trim()
          : normalizedToken;

      if (normalizedField.isEmpty ||
          !fieldNameRegExp.hasMatch(normalizedField)) {
        final strayArgs = trailingArgs.join(' ');
        throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
      }

      _trailingFieldTokens.add(normalizedField);
    }
  }

  @override
  List<String> resolveFormFields() {
    final rawValues =
        argResults?['fields'] as List<String>? ?? const <String>[];
    final normalizedFields = LinkedHashSet<String>();

    for (final rawValue in rawValues) {
      final segments = rawValue.split(',');
      for (final segment in segments) {
        final field = segment.trim();
        if (field.isNotEmpty) {
          normalizedFields.add(field);
        }
      }
    }

    normalizedFields.addAll(_trailingFieldTokens);

    if (normalizedFields.isEmpty) {
      throw UsageException('Missing required option(s): --fields', usage);
    }

    final fieldNameRegExp = RegExp(CliRules.sliceNamePattern);
    for (final field in normalizedFields) {
      if (!fieldNameRegExp.hasMatch(field)) {
        throw UsageException(
          'Invalid field name "$field".\n${CliRules.sliceNameRule}',
          usage,
        );
      }
    }

    return normalizedFields.toList(growable: false);
  }
}
