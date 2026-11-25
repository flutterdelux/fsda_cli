import 'package:path/path.dart' as p;

import '../../core/constants/cli_info.dart';
import '../../domain/params/workspace_param.dart';
import '../bundles/package_bundle.dart';
import '../templates/config_template.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class WorkspaceService {
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final FileService _fileService;

  const WorkspaceService({
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required FileService fileService,
  }) : _reportService = reportService,
       _directoryService = directoryService,
       _fileService = fileService;

  Future<void> generate({
    required WorkspaceParam workspace,
    required Function(String) onProgress,
  }) async {
    onProgress('Creating directory structures...');
    await _createDirectoryStructure(workspace);

    onProgress(
      'Generating ${CliInfo.fsdaDirName}/${CliInfo.configFileName} configuration...',
    );
    await _createConfigYaml(workspace);
  }

  Future<void> _createDirectoryStructure(WorkspaceParam workspace) async {
    final fsdaDir = p.join(workspace.workspacePath, CliInfo.fsdaDirName);
    final dirToCreate = [
      fsdaDir,
      p.join(fsdaDir, CliInfo.plansDirName),
      p.join(workspace.workspacePath, 'apps'),
      p.join(workspace.workspacePath, 'modules'),
      p.join(workspace.workspacePath, 'packages'),
    ];
    for (final path in dirToCreate) {
      await _directoryService.create(path);
      _reportService.addCreated(path);
    }
  }

  Future<void> _createConfigYaml(WorkspaceParam workspace) async {
    final path = p.join(
      workspace.workspacePath,
      CliInfo.fsdaDirName,
      CliInfo.configFileName,
    );
    final packages = packageBundle.keys.toList();

    final content = ConfigTemplate.buildConfig(
      workspaceName: workspace.workspaceName,
      packages: packages,
    );

    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }
}
