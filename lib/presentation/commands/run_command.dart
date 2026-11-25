import '../../domain/params/workspace_param.dart';
import '../../infrastructure/services/run_service.dart';
import 'wrapper/workspace_guard_command.dart';

class RunCommand extends WorkspaceGuardCommand {
  final RunService _runService;

  RunCommand({
    required RunService runService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _runService = runService;

  @override
  String get name => 'run';

  @override
  String get description => 'Run FSDA CLI Base.';

  @override
  String get invocation => 'fsda $name';

  @override
  Future<int> handle(WorkspaceParam workspace) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    try {
      await _runService.runScript(workspace);
      return successCode;
    } catch (e) {
      logger.error(e.toString().replaceFirst('Exception: ', ''));
      return errorSystem;
    }
  }
}
