import 'dart:io';
import 'package:args/command_runner.dart';

import '../../core/constants/workspace_rules.dart';
import '../../infrastructure/services/workspace_service.dart';
import '../../models/workspace.dart';
import '../cli_logger.dart';

class CreateWorkspaceCommand extends Command {
  final CliLogger _logger;
  final WorkspaceService _workspaceService;

  CreateWorkspaceCommand({
    required CliLogger logger,
    required WorkspaceService workspaceService,
  }) : _logger = logger,
       _workspaceService = workspaceService;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new FSDA workspace wrapper structure.';

  @override
  String get invocation => 'fsda create <workspace_name>';

  @override
  void run() async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      _logger.error('Workspace name is required.');
      _logger.log('Usage: $invocation');
      exitCode = 64;
      return;
    }

    final workspaceName = rest.first;

    // Validasi aturan snake_case
    if (!WorkspaceRules.snakeCaseRegex.hasMatch(workspaceName)) {
      _logger.error('Invalid workspace name: "$workspaceName".');
      _logger.error(WorkspaceRules.namingRuleDescription);
      exitCode = 64;
      return;
    }

    final workspace = Workspace(
      name: workspaceName,
      path: '${Directory.current.path}/$workspaceName',
    );

    final progress = _logger.progress('Creating workspace "$workspaceName"...');

    try {
      // Panggil service dan dapatkan buffer laporan
      final reportBuffer = await _workspaceService.generate(
        workspace,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Workspace "$workspaceName" created successfully!');
      _logger.log('');

      // Cetak laporan ringkasan perubahan ke terminal
      _logger.log(reportBuffer.toString());
    } catch (e) {
      progress.fail('Failed to create workspace: $e');
      exitCode = 1;
    }
  }
}
