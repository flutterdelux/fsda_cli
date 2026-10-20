import 'dart:io';
import '../../models/workspace.dart';
import '../bundles/package_bundle.dart';
import '../templates/workspace_template.dart';
import 'operation_report_service.dart';

class WorkspaceService {
  final OperationReportService _reportService;

  WorkspaceService({required OperationReportService reportService})
    : _reportService = reportService;

  Future<StringBuffer> generate(
    Workspace workspace, {
    required Function(String) onProgress,
  }) async {
    final targetDirectory = Directory(workspace.path);
    if (await targetDirectory.exists()) {
      throw Exception(
        'Workspace directory "${workspace.name}" already exists.',
      );
    }

    onProgress('Creating directory structures...');

    // 1. Buat direktori utama dan catat ke report accumulator
    final appsDir = Directory('${targetDirectory.path}/apps');
    await appsDir.create(recursive: true);
    _reportService.addCreated(appsDir.path);

    final modulesDir = Directory('${targetDirectory.path}/modules');
    await modulesDir.create(recursive: true);
    _reportService.addCreated(modulesDir.path);

    final packagesDir = Directory('${targetDirectory.path}/packages');
    await packagesDir.create(recursive: true);
    _reportService.addCreated(packagesDir.path);

    onProgress('Generating fsda.yaml configuration...');
    await _generateFsdaYaml(workspace);

    // 2. Kembalikan hasil buffer laporan akhir ke command
    return _reportService.generateReport(
      operationLabel: 'Create Workspace Summary',
    );
  }

  Future<void> _generateFsdaYaml(Workspace workspace) async {
    final yamlFile = File('${workspace.path}/fsda.yaml');
    final packages = packageBundle.keys.toList();

    final buffer = WorkspaceTemplate.buildFsda(
      workspaceName: workspace.name,
      packages: packages,
    );

    await yamlFile.writeAsString(buffer.toString());
    _reportService.addCreated(yamlFile.path);
  }
}
