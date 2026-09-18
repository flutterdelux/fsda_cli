import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/domain/dto_generator.dart';
import '../../models/generation/typed_prop.dart';
import '../../services/parsing/typed_prop_parser_service.dart';
import '../../services/workspace_service.dart';

class DtoCommand extends Command<void> {
  final DtoGenerator dtoGenerator;
  final WorkspaceService workspaceService;
  final TypedPropParserService typedPropParser;
  final _trailingPropTokens = <String>[];

  DtoCommand({
    required this.dtoGenerator,
    required this.workspaceService,
    TypedPropParserService? typedPropParser,
  }) : typedPropParser = typedPropParser ?? const TypedPropParserService() {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addMultiOption(
        'props',
        help:
            'Required properties with syntax type:name or type:name=default. Repeat --props or pass comma-separated values. In zsh, wrap value with quotes when nullable type (?) exists.',
      )
      ..addFlag(
        'strict',
        negatable: false,
        help:
            'Fail when command would skip generation due existing files or unsafe injection targets.',
      )
      ..addFlag(
        'hook-disabled',
        negatable: false,
        help:
            'Skip post-hook execution and print manual next steps to run afterward.',
      );
  }

  @override
  final String name = 'dto';

  @override
  final String description =
      'Generate DTO model only with freezed serialization and toEntity mapper.';

  @override
  String get invocation =>
      'fsda dto <prefix> -m <module> -f <feature> --props "<type:prop_1,type:prop_2,...>" [--strict] [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    _trailingPropTokens.clear();
    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing dto prefix.', usage);
    }

    _collectTrailingPropTokens(args.skip(1).toList(growable: false));

    final prefix = args.first.trim();
    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final strict = argResults?['strict'] as bool? ?? false;
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;

    if (prefix.isEmpty) {
      throw UsageException('Dto prefix cannot be empty.', usage);
    }

    final prefixPattern = RegExp(CliRules.artifactPrefixPattern);
    if (!prefixPattern.hasMatch(prefix)) {
      throw UsageException(
        'Invalid dto prefix "$prefix".\n${CliRules.artifactPrefixRule}',
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

    await dtoGenerator.generate((
      prefix: prefix,
      feature: feature,
      module: module,
      props: props,
      strict: strict,
      hookDisabled: hookDisabled,
    ));
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
        _trailingPropTokens.add(normalizedValue);
      }
    }
  }
}
