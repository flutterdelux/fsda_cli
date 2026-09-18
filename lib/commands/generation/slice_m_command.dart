import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/slice_generator.dart';
import '../../services/workspace_service.dart';

class SliceMCommand extends Command<void> {
  final SliceGenerator sliceGenerator;
  final WorkspaceService workspaceService;

  SliceMCommand({
    required this.sliceGenerator,
    required this.workspaceService,
  }) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption('method', abbr: 'd', help: 'Mutation method name.')
      ..addFlag(
        'hook-disabled',
        negatable: false,
        help:
            'Skip post-hook execution and print manual next steps to run afterward.',
      );
  }

  @override
  final String name = 'slice-m';

  @override
  final String description =
      'Generate mutation slice without Param and reuse existing feature artifacts.';

  @override
  String get invocation =>
      'fsda slice-m <slice> -f <feature> -m <module> -d <method> [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing slice name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final slice = args.first;
    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final method = argResults?['method'] as String?;
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');
    if (method == null || method.isEmpty) missingFlags.add('--method');

    if (missingFlags.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missingFlags.join(', ')}',
        usage,
      );
    }

    final sliceNameRegExp = RegExp(CliRules.sliceNamePattern);
    if (!sliceNameRegExp.hasMatch(slice)) {
      throw UsageException(
        'Invalid slice name "$slice".\n${CliRules.sliceNameRule}',
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

    final methodNameRegExp = RegExp(CliRules.methodNamePattern);
    if (!methodNameRegExp.hasMatch(method!)) {
      throw UsageException(
        'Invalid method name "$method".\n${CliRules.methodNameRule}',
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

    await sliceGenerator.generateSliceM((
      slice: slice,
      feature: feature,
      module: module,
      method: method,
      hookDisabled: hookDisabled,
    ));
  }
}
