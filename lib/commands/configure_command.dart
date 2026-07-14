import 'package:args/command_runner.dart';

import '../generators/configure_generator.dart';
import '../services/logger_service.dart';
import '../services/workspace_service.dart';

class ConfigureCommand extends Command {
  final ConfigureGenerator initGenerator;
  final LoggerService logger;
  final WorkspaceService workspaceService;

  ConfigureCommand({
    required this.initGenerator,
    required this.logger,
    required this.workspaceService,
  });

  @override
  final String name = 'configure';

  @override
  final String description =
      'Synchronize workspace/packages from active fsda.yaml packages list.';

  @override
  String get invocation => 'fsda configure';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;

    if (args.isNotEmpty) {
      throw UsageException(
        'This command does not accept any arguments.\n'
        'Use the standard format: fsda configure',
        usage,
      );
    }

    await initGenerator.generate();
  }
}
