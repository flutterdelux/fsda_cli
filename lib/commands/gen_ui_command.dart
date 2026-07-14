import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';

class GenUiCommand extends Command<void> {
  final UiGenerator uiGenerator;
  final WorkspaceService workspaceService;

  GenUiCommand({required this.uiGenerator, required this.workspaceService}) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption(
        'ui',
        abbr: 'u',
        help:
            'UI code. Current supported code: ${UiCode.values.map((e) => e.code).join(', ')}',
      );
  }

  @override
  final String name = 'gen-ui';

  @override
  final String description =
      'Generate a UI template in target feature and inject its ARB/export manifest.';

  @override
  String get invocation =>
      'fsda gen-ui <slice> -f <feature> -m <module> -u <ui_code>';

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

    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final ui = argResults?['ui'] as String?;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');
    if (ui == null || ui.isEmpty) missingFlags.add('--ui');

    if (missingFlags.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missingFlags.join(', ')}',
        usage,
      );
    }

    final slice = args.first;

    final sliceNameRegExp = RegExp(CliRules.sliceNamePattern);
    if (!sliceNameRegExp.hasMatch(slice)) {
      throw UsageException(
        'Invalid slice name "$slice".\n'
        '${CliRules.sliceNameRule}',
        usage,
      );
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature!)) {
      throw UsageException(
        'Invalid feature name "$feature".\n'
        '${CliRules.featureNameRule}',
        usage,
      );
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module!)) {
      throw UsageException(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
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

    UiCode uiCode;
    try {
      uiCode = UiCode.fromValue(ui);
    } catch (e) {
      throw UsageException(e.toString(), usage);
    }

    await uiGenerator.generate((
      slice: slice,
      feature: feature,
      module: module,
      ui: uiCode,
    ));
  }
}
