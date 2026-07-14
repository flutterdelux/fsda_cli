import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../generators/di_generator.dart';
import '../services/workspace_service.dart';

class DiCommand extends Command {
  final DiGenerator diGenerator;
  final WorkspaceService workspaceService;

  @override
  final String name = 'di';

  @override
  final String description =
      'Register DI for a specific feature in a target app/module wrapper.';

  DiCommand({required this.diGenerator, required this.workspaceService}) {
    argParser
      ..addOption(
        'app',
        abbr: 'a',
        help: 'Target application name (e.g., fsda_demo)',
      )
      ..addOption(
        'module',
        abbr: 'm',
        help: 'Target module name (e.g., finance).',
      );
  }

  @override
  String get invocation => 'fsda di <feature> -m <module> -a <app>';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing feature name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final feature = args.first;
    final app = argResults?['app'] as String?;
    final module = argResults?['module'] as String?;

    if (app == null || module == null) {
      throw UsageException(
        'Both --app (-a) and --module (-m) options are required.',
        usage,
      );
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature)) {
      throw UsageException(
        'Invalid feature name "$feature".\n'
        '${CliRules.featureNameRule}',
        usage,
      );
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

    await diGenerator.generate((feature: feature, module: module, app: app));
  }
}
