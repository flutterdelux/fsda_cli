import 'package:path/path.dart' as p;

import '../../core/extensions/workspace_param_x.dart';
import '../../domain/params/workspace_param.dart';
import 'helpers/file_service.dart';
import 'helpers/process_service.dart';

class RunService {
  final ProcessService _processService;
  final FileService _fileService;

  const RunService({
    required ProcessService processService,
    required FileService fileService,
  }) : _processService = processService,
       _fileService = fileService;

  Future<void> runScript(WorkspaceParam workspace) async {
    final scriptPath = workspace.runPath;
    final relativePath = p.relative(scriptPath, from: workspace.workspacePath);

    if (!await _fileService.exists(scriptPath)) {
      throw Exception('Script file not found at: $scriptPath');
    }

    await _processService.runStream('bash', [
      relativePath,
    ], workspace.workspacePath);
  }
}
