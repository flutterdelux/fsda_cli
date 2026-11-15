import 'package:path/path.dart' as p;

import '../../core/extensions/feature_gate_param_x.dart';
import '../../domain/models/artifact_generation_model.dart';
import '../../domain/params/logic_flow_param.dart';
import '../../domain/params/logic_param.dart';
import '../templates/logics/logic_template.dart';
import '../templates/logics/state_flow_template.dart';
import '../templates/logics/state_template.dart';
import 'helpers/export_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_resolver_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';

class LogicService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final ImportService _importService;
  final ImportResolverService _importResolverService;
  final ExportService _exportService;

  const LogicService({
    required OperationReportService reportService,
    required FileService fileService,
    required ImportService importService,
    required ImportResolverService importResolverService,
    required ExportService exportService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _importService = importService,
       _importResolverService = importResolverService,
       _exportService = exportService;

  Future<void> generate({
    required LogicParam logic,
    required void Function(String) onProgress,
  }) async {
    final stateArtifact = StateTemplate.build(logic);
    if (!await _fileService.exists(stateArtifact.path)) {
      onProgress(
        'Creating state file, resolve import and export to feature barrel...',
      );
      await _createFileResolveImportAndExport(
        artifact: stateArtifact,
        modulePath: logic.modulePath,
        featureBarrelPath: logic.featureBarrelPath,
      );
    }

    onProgress(
      'Creating logic file, resolve import and export to feature barrel...',
    );
    final logicArtifact = LogicTemplate.build(logic);
    await _createFileResolveImportAndExport(
      artifact: logicArtifact,
      modulePath: logic.modulePath,
      featureBarrelPath: logic.featureBarrelPath,
    );
  }

  Future<void> generateFlow({
    required LogicFlowParam logic,
    required void Function(String) onProgress,
  }) async {
    final stateArtifact = StateFlowTemplate.build(logic);
    if (!await _fileService.exists(stateArtifact.path)) {
      onProgress(
        'Creating state file, resolve import and export to feature barrel...',
      );
      await _createFileResolveImportAndExport(
        artifact: stateArtifact,
        modulePath: logic.modulePath,
        featureBarrelPath: logic.featureBarrelPath,
      );
    }

    onProgress(
      'Creating logic file, resolve import and export to feature barrel...',
    );
    final logicArtifact = LogicTemplate.buildFlow(logic);
    await _createFileResolveImportAndExport(
      artifact: logicArtifact,
      modulePath: logic.modulePath,
      featureBarrelPath: logic.featureBarrelPath,
    );
  }

  // ========= Generation helper =============

  Future<void> _createFileResolveImportAndExport({
    required ArtifactGenerationModel artifact,
    required String modulePath,
    required String featureBarrelPath,
  }) async {
    final path = artifact.path;
    final content = artifact.content;
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);

    if (artifact.typesToImport.isNotEmpty) {
      final imports = await _importResolverService.resolve(
        rawTypes: artifact.typesToImport,
        targetFilePath: path,
        modulePath: modulePath,
      );
      await _importService.injectImport(path: path, imports: imports);
    }

    if (artifact.needToExport) {
      final barrelPath = featureBarrelPath;
      final relativePath = p.relative(path, from: p.dirname(barrelPath));
      await _exportService.inject(
        barrelPath: barrelPath,
        exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
        checkpoint: '// logic',
      );
      _reportService.addInjected(barrelPath);
    }
  }
}
