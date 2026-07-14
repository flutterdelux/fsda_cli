import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../generators/rm_reg_module_generator.dart';
import '../services/workspace_service.dart';

class RmRegCommand extends Command<void> {
  final RmRegModuleGenerator rmRegModuleGenerator;
  final WorkspaceService workspaceService;

  RmRegCommand({
    required this.rmRegModuleGenerator,
    required this.workspaceService,
  }) {
    argParser.addOption('app', abbr: 'a', help: 'Target app name.');
  }

  @override
  final String name = 'rm-reg';

  @override
  final String description = 'Remove module registration from target app.';

  @override
  String get invocation => 'fsda rm-reg <module> -a <app>';

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

    final app = argResults?['app'] as String?;
    if (app == null || app.isEmpty) {
      throw UsageException('Missing required option: --app (-a).', usage);
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
    if (!appNameRegExp.hasMatch(app)) {
      throw UsageException(
        'Invalid app name "$app".\n'
        '${CliRules.appNameRule}',
        usage,
      );
    }

    await rmRegModuleGenerator.generate((app: app, module: module));
  }
}
