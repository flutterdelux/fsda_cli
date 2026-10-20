import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/modelling/param_request_generator.dart';
import '../../models/generation/typed_prop.dart';
import '../../services/command_operation_service.dart';
import '../../services/parsing/typed_prop_parser_service.dart';
import '../../services/workspace_service.dart';

class ParamRequestCommand extends Command<void> {
  final ParamRequestGenerator paramRequestGenerator;
  final WorkspaceService workspaceService;
  final TypedPropParserService typedPropParser;
  final CommandOperationService operations;
  final _trailingPropTokens = <String>[];

  ParamRequestCommand({
    required this.paramRequestGenerator,
    required this.workspaceService,
    required this.operations,
    TypedPropParserService? typedPropParser,
  }) : typedPropParser = typedPropParser ?? const TypedPropParserService() {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addMultiOption(
        'props',
        help:
            'Required properties with syntax type:name or type:name=default. Repeat --props or pass comma-separated values.',
      )
      ..addFlag(
        'strict',
        negatable: false,
        help: 'Fail when command would skip generation due existing files.',
      )
      ..addFlag(
        'hook-disabled',
        negatable: false,
        help: 'Skip post-hook execution.',
      );
  }

  @override
  final String name = 'param-request';

  @override
  final String description =
      'Generate both Param and Request models simultaneously with shared properties.';

  @override
  String get invocation =>
      'fsda param-request <prefix> -m <module> -f <feature> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    _trailingPropTokens.clear();
    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing prefix name.', usage);
    }

    _collectTrailingPropTokens(args.skip(1).toList(growable: false));

    final prefix = args.first.trim();
    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final strict = argResults?['strict'] as bool? ?? false;
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;

    if (prefix.isEmpty) {
      throw UsageException('Prefix name cannot be empty.', usage);
    }

    final namePattern = RegExp(r'^[a-z][a-z0-9_]*$');
    if (!namePattern.hasMatch(prefix) ||
        prefix.endsWith('_param') ||
        prefix.endsWith('_request')) {
      throw UsageException(
        'Invalid prefix "$prefix". It must be snake_case without suffixes like _param or _request.',
        usage,
      );
    }

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');

    if (missingFlags.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missingFlags.join(', ')}',
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

    final optionValues = argResults?['props'] as List<String>? ?? const [];
    final props = _resolveProps(optionValues);

    await operations.run<Map<String, dynamic>>(
      operationLabel: 'fsda param-request $prefix',
      hookDisabled: hookDisabled,
      action: () => paramRequestGenerator.generate((
        prefix: prefix,
        feature: feature,
        module: module,
        props: props,
        strict: strict,
      )),
      hookResults: (result) => [result],
    );
  }

  List<TypedProp> _resolveProps(List<String> optionValues) {
    try {
      return typedPropParser.parse(
        optionValues: optionValues,
        trailingValues: _trailingPropTokens,
      );
    } on FormatException catch (e) {
      throw UsageException(e.message, usage);
    }
  }

  void _collectTrailingPropTokens(List<String> trailingArgs) {
    if (trailingArgs.isEmpty) return;
    for (final token in trailingArgs) {
      final normalizedToken = token.trim();
      if (normalizedToken.isEmpty) continue;
      final normalizedValue = normalizedToken
          .replaceFirst(RegExp(r'^,+'), '')
          .replaceFirst(RegExp(r',+$'), '')
          .trim();
      if (normalizedValue.isNotEmpty) {
        _trailingPropTokens.add(normalizedValue);
      }
    }
  }
}
