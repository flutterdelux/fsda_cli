import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../generators/reg_module_generator.dart';
import '../services/workspace_service.dart';

class RegCommand extends Command {
  final RegModuleGenerator regModuleGenerator;
  final WorkspaceService workspaceService;

  RegCommand({
    required this.regModuleGenerator,
    required this.workspaceService,
  }) {
    argParser.addOption('app', abbr: 'a', help: 'The name of the target app.');
  }

  @override
  final String name = 'reg';

  @override
  final String description = 'Compose module, feature to target app.';

  @override
  String get invocation => 'fsda reg <module> -a <app>';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;

    if (args.isEmpty) {
      throw UsageException('Missing module name.', usage);
    }

    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException(
        'Unexpected argument(s): "$strayArgs".\n'
        'Only one positional argument is allowed: the module name.',
        usage,
      );
    }

    final appName = argResults?['app'] as String?;
    if (appName == null || appName.isEmpty) {
      throw UsageException('Missing required flag: --app (-a).', usage);
    }

    final module = args.first;
    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module)) {
      throw UsageException(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
        usage,
      );
    }

    final appNameRegExp = RegExp(CliRules.appNamePattern);
    if (!appNameRegExp.hasMatch(appName)) {
      throw UsageException(
        'Invalid app name "$appName".\n'
        '${CliRules.appNameRule}',
        usage,
      );
    }

    await regModuleGenerator.generate((app: appName, module: module));
  }
}
