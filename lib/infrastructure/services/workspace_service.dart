import 'package:path/path.dart' as p;

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

    onProgress('Generating fsda.yaml configuration...');
    await _createFsdaYaml(workspace);
  }

  Future<void> _createDirectoryStructure(WorkspaceParam workspace) async {
    final dirToCreate = [
      p.join(workspace.path, 'apps'),
      p.join(workspace.path, 'modules'),
      p.join(workspace.path, 'packages'),
    ];
    for (final path in dirToCreate) {
      await _directoryService.create(path);
      _reportService.addCreated(path);
    }
  }

  Future<void> _createFsdaYaml(WorkspaceParam workspace) async {
    final path = '${workspace.path}/fsda.yaml';
    final packages = packageBundle.keys.toList();

    final content = ConfigTemplate.buildFsda(
      workspaceName: workspace.name,
      packages: packages,
    );

    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }
}
