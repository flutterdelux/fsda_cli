import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/workspace_param.dart';
import '../../infrastructure/services/helpers/directory_service.dart';
import '../../infrastructure/services/helpers/operation_report_service.dart';
import '../../infrastructure/services/workspace_service.dart';
import '../cli_logger.dart';
import 'wrapper/base_command.dart';

class CreateWorkspaceCommand extends BaseCommand {
  final CliLogger _logger;
  final WorkspaceService _workspaceService;
  final DirectoryService _directoryService;
  final OperationReportService _reportService;

  CreateWorkspaceCommand({
    required CliLogger logger,
    required WorkspaceService workspaceService,
    required DirectoryService directoryService,
    required OperationReportService reportService,
  }) : _logger = logger,
       _workspaceService = workspaceService,
       _directoryService = directoryService,
       _reportService = reportService;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new FSDA workspace wrapper structure.';

  @override
  String get invocation => 'fsda $name <workspace_name>';

  @override
  Future<int> run() async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      _logger.error('Workspace name is required.');
      _logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      _logger.error('Invalid workspace name: "$rest".');
      _logger.log(Rules.workspaceDescription);
      _logger.log('Usage: $invocation');
      return errorUsage;
    }

    final workspaceName = rest.first;

    // Validasi aturan snake_case
    if (!Rules.workspaceRegExp.hasMatch(workspaceName)) {
      _logger.error('Invalid workspace name: "$workspaceName".');
      _logger.log(Rules.workspaceDescription);
      _logger.log('Usage: $invocation');
      return errorUsage;
    }

    final workspacePath = p.join(_directoryService.currentPath, workspaceName);

    if (await _directoryService.exists(workspacePath)) {
      _logger.error(
        'Workspace "$workspaceName" already exists at $workspacePath',
      );
      _logger.log('Usage: $invocation');
      return errorUsage;
    }

    final workspace = WorkspaceParam(name: workspaceName, path: workspacePath);

    final progress = _logger.progress('Creating workspace "$workspaceName"...');

    try {
      await _workspaceService.generate(
        workspace: workspace,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Workspace "$workspaceName" created successfully!');

      final reportBuffer = _reportService.generateReport(
        operationLabel: 'Create Workspace Summary',
      );
      _logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to create workspace: $e');
      return errorSystem;
    }
  }
}
