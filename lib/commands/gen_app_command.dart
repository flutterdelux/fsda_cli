import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../generators/app_generator.dart';
import '../services/workspace_service.dart';

class GenAppCommand extends Command<void> {
  final AppGenerator appGenerator;
  final WorkspaceService workspaceService;

  GenAppCommand({required this.appGenerator, required this.workspaceService});

  @override
  final String name = 'gen-app';

  @override
  final String description = 'Generate a Flutter app in workspace/apps/<app>.';

  @override
  String get invocation => 'fsda gen-app <app>';

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

    final app = args.first;

    final appNameRegExp = RegExp(CliRules.appNamePattern);
    if (!appNameRegExp.hasMatch(app)) {
      throw UsageException(
        'Invalid app name "$app".\n'
        '${CliRules.appNameRule}',
        usage,
      );
    }

    await appGenerator.generate((app: app));
  }
}
