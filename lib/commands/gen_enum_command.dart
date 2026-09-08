import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../generators/enum_generator.dart';
import '../services/workspace_service.dart';

class GenEnumCommand extends Command<void> {
  final EnumGenerator enumGenerator;
  final WorkspaceService workspaceService;
  final _trailingValueTokens = <String>[];

  GenEnumCommand({
    required this.enumGenerator,
    required this.workspaceService,
  }) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addMultiOption(
        'values',
        help:
            'Required enum values in snake_case. Repeat --values or pass comma-separated values.',
      )
      ..addFlag(
        'strict',
        negatable: false,
        help:
            'Fail when command would skip generation due existing files or unsafe injection targets.',
      );
  }

  @override
  final String name = 'gen-enum';

  @override
  final String description =
      'Generate enum domain/converter/localization extension and inject ARB/export entries.';

  @override
  String get invocation =>
      'fsda gen-enum <enum_name> -f <feature> -m <module> --values <value_1,value_2,...> [--strict]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    _trailingValueTokens.clear();
    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing enum name.', usage);
    }

    _collectTrailingValueTokens(args.skip(1).toList(growable: false));

    final enumName = args.first;
    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final strict = argResults?['strict'] as bool? ?? false;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');

    if (missingFlags.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missingFlags.join(', ')}',
        usage,
      );
    }

    final enumNameRegExp = RegExp(CliRules.sliceNamePattern);
    if (!enumNameRegExp.hasMatch(enumName)) {
      throw UsageException(
        'Invalid enum name "$enumName".\n${CliRules.sliceNameRule}',
        usage,
      );
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature!)) {
      throw UsageException(
        'Invalid feature name "$feature".\n${CliRules.featureNameRule}',
        usage,
      );
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module!)) {
      throw UsageException(
        'Invalid module name "$module".\n${CliRules.moduleNameRule}',
        usage,
      );
    }

    final values = _resolveEnumValues();

    final moduleDir = Directory(
      p.join(Directory.current.path, 'modules', module),
    );
    if (!await moduleDir.exists()) {
      throw UsageException('Module "$module" does not exist.', usage);
    }

    final featureDir = Directory(
      p.join(moduleDir.path, 'lib', 'src', 'features', feature),
    );
    if (!await featureDir.exists()) {
      throw UsageException(
        'Feature "$feature" does not exist in module "$module".',
        usage,
      );
    }

    await enumGenerator.generate((
      enumName: enumName,
      feature: feature,
      module: module,
      values: values,
      strict: strict,
    ));
  }

  void _collectTrailingValueTokens(List<String> trailingArgs) {
    if (trailingArgs.isEmpty) {
      return;
    }

    final valueRegExp = RegExp(CliRules.sliceNamePattern);
    for (final token in trailingArgs) {
      final normalizedToken = token.trim();
      if (normalizedToken.isEmpty) {
        continue;
      }

      final normalizedValue = normalizedToken
          .replaceFirst(RegExp(r'^,+'), '')
          .replaceFirst(RegExp(r',+$'), '')
          .trim();

      if (normalizedValue.isEmpty || !valueRegExp.hasMatch(normalizedValue)) {
        final strayArgs = trailingArgs.join(' ');
        throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
      }

      _trailingValueTokens.add(normalizedValue);
    }
  }

  List<String> _resolveEnumValues() {
    final rawValues = argResults?['values'] as List<String>? ?? const [];
    final normalizedValues = <String>{};

    for (final rawValue in rawValues) {
      final segments = rawValue.split(',');
      for (final segment in segments) {
        final value = segment.trim();
        if (value.isNotEmpty) {
          normalizedValues.add(value);
        }
      }
    }

    normalizedValues.addAll(_trailingValueTokens);

    if (normalizedValues.isEmpty) {
      throw UsageException('Missing required option(s): --values', usage);
    }

    final valueRegExp = RegExp(CliRules.sliceNamePattern);
    for (final value in normalizedValues) {
      if (!valueRegExp.hasMatch(value)) {
        throw UsageException(
          'Invalid enum value "$value".\n${CliRules.sliceNameRule}',
          usage,
        );
      }
    }

    return normalizedValues.toList(growable: false);
  }
}
