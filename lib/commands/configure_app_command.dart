import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../generators/configure_app_generator.dart';
import '../services/workspace_service.dart';

class ConfigureAppCommand extends Command<void> {
  final ConfigureAppGenerator configureAppGenerator;
  final WorkspaceService workspaceService;

  ConfigureAppCommand({
    required this.configureAppGenerator,
    required this.workspaceService,
  });

  @override
  final String name = 'configure-app';

  @override
  final String description =
      'Synchronize app package dependencies with workspace/packages.';

  @override
  String get invocation => 'fsda configure-app <app>';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing app name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final appName = args.first;
    final appNameRegExp = RegExp(CliRules.appNamePattern);
    if (!appNameRegExp.hasMatch(appName)) {
      throw UsageException(
        'Invalid app name "$appName".\n'
        '${CliRules.appNameRule}',
        usage,
      );
    }

    await configureAppGenerator.generate(appName);
  }
}
