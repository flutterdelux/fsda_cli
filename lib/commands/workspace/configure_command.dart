import 'package:args/command_runner.dart';

import '../../generators/configure_generator.dart';
import '../../services/command_operation_service.dart';
import '../../services/logger_service.dart';
import '../../services/workspace_service.dart';

class ConfigureCommand extends Command {
  final ConfigureGenerator initGenerator;
  final LoggerService logger;
  final WorkspaceService workspaceService;
  final CommandOperationService operations;

  ConfigureCommand({
    required this.initGenerator,
    required this.logger,
    required this.workspaceService,
    required this.operations,
  }) {
    argParser.addFlag(
      'hook-disabled',
      negatable: false,
      help:
          'Skip post-hook execution and print manual next steps to run afterward.',
    );
  }

  @override
  final String name = 'configure';

  @override
  final String description =
      'Synchronize workspace/packages from active fsda.yaml packages list.';

  @override
  String get invocation => 'fsda configure [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;

    if (args.isNotEmpty) {
      throw UsageException(
        'This command does not accept any arguments.\n'
        'Use the standard format: fsda configure',
        usage,
      );
    }

    await operations.run<List<Map<String, dynamic>>>(
      operationLabel: 'fsda configure',
      hookDisabled: hookDisabled,
      action: initGenerator.generate,
      hookResults: (results) => results,
    );
  }
}
