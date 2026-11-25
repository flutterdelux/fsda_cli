import 'dart:io';

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

    final bashExecutable = _resolveBashExecutable();
    try {
      await _processService.runStream(bashExecutable, [
        relativePath,
      ], workspace.workspacePath);
    } on ProcessException {
      throw Exception(
        'Bash executable not found. On Windows, please install Git for Windows or run inside Git Bash.',
      );
    }
  }

  String _resolveBashExecutable() {
    if (!Platform.isWindows) return 'bash';

    // Lokasi umum bash.exe milik Git for Windows
    final commonPaths = [
      r'C:\Program Files\Git\bin\bash.exe',
      r'C:\Program Files (x86)\Git\bin\bash.exe',
      p.join(
        Platform.environment['LOCALAPPDATA'] ?? '',
        'Programs',
        'Git',
        'bin',
        'bash.exe',
      ),
    ];

    for (final path in commonPaths) {
      if (_fileService.existsSync(path)) {
        return path;
      }
    }

    // Fallback ke 'bash' jika ada di PATH
    return 'bash';
  }
}
