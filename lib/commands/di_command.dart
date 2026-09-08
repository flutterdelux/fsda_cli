import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../generators/di_generator.dart';
import '../services/workspace_service.dart';

class DiCommand extends Command<void> {
  final DiGenerator diGenerator;
  final WorkspaceService workspaceService;

  @override
  final String name = 'di';

  @override
  final String description =
      'Register DI for a module in target app wrapper (scans all features by default).';

  DiCommand({required this.diGenerator, required this.workspaceService}) {
    argParser
      ..addOption(
        'app',
        abbr: 'a',
        help: 'Target application name (e.g., fsda_demo)',
      )
      ..addOption(
        'feature',
        abbr: 'f',
        help:
            'Optional feature filter. When omitted, all features in module are scanned.',
      )
      ..addFlag(
        'strict',
        negatable: false,
        help: 'Fail when required DI injection cannot be applied safely.',
      );
  }

  @override
  String get invocation =>
      'fsda di <module> -a <app> [-f <feature>] [--strict]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing module name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final module = args.first;
    final app = argResults?['app'] as String?;
    final featureFilter = (argResults?['feature'] as String?)?.trim();
    final strict = argResults?['strict'] as bool? ?? false;

    if (app == null || app.isEmpty) {
      throw UsageException('Missing required option: --app (-a).', usage);
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module)) {
      throw UsageException(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
        usage,
      );
    }

    final appNameRegExp = RegExp(CliRules.appNamePattern);
    if (!appNameRegExp.hasMatch(app)) {
      throw UsageException(
        'Invalid app name "$app".\n'
        '${CliRules.appNameRule}',
        usage,
      );
    }

    final moduleDir = p.join(Directory.current.path, 'modules', module);
    if (!Directory(moduleDir).existsSync()) {
      throw UsageException('Module "$module" does not exist.', usage);
    }

    final feature = featureFilter?.isEmpty == true ? null : featureFilter;
    if (feature != null) {
      final featureNameRegExp = RegExp(CliRules.featureNamePattern);
      if (!featureNameRegExp.hasMatch(feature)) {
        throw UsageException(
          'Invalid feature name "$feature".\n${CliRules.featureNameRule}',
          usage,
        );
      }

      final featureDir = p.join(moduleDir, 'lib', 'src', 'features', feature);
      if (!Directory(featureDir).existsSync()) {
        throw UsageException(
          'Feature "$feature" does not exist in module "$module".',
          usage,
        );
      }
    }

    await diGenerator.generate((
      module: module,
      app: app,
      feature: feature,
      strict: strict,
    ));
  }
}
