import 'package:path/path.dart' as p;

import '../../core/extensions/feature_param_x.dart';
import '../../domain/params/feature_param.dart';
import '../templates/feature_template.dart';
import '../templates/repositories/repository_template.dart';
import 'helpers/arb_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/export_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class FeatureService {
  final OperationReportService _reportService;
  final ExportService _exportService;
  final DirectoryService _directoryService;
  final FileService _fileService;
  final ArbService _arbService;

  const FeatureService({
    required OperationReportService reportService,
    required ExportService exportService,
    required DirectoryService directoryService,
    required FileService fileService,
    required ArbService arbService,
  }) : _reportService = reportService,
       _exportService = exportService,
       _directoryService = directoryService,
       _fileService = fileService,
       _arbService = arbService;

  Future<void> generateFeature({
    required FeatureParam feature,
    required Function(String) onProgress,
  }) async {
    onProgress('Creating feature directory...');
    await _createFeatureDirectory(feature);

    onProgress('Creating feature folder structure...');
    await _createFolderStructure(feature);

    onProgress('Creating feature barrel file...');
    await _createFeatureBarrel(feature);

    onProgress('Creating repository interface and export to feature barrel...');
    await _createRepoInterface(feature);

    onProgress('Creating repository impl and export to feature barrel...');
    await _createRepoImpl(feature);

    onProgress('Injecting export feature to module barrel...');
    await _injectExportFeatureToModuleBarrel(feature);

    onProgress('Injecting initial arb template for feature...');
    await _injectFeatureArb(feature);
  }

  Future<void> removeFeature({
    required FeatureParam feature,
    required Function(String) onProgress,
  }) async {
    onProgress('Removing feature "${feature.name}" directory...');
    await _removeFeatureDirectory(feature);

    onProgress('Unject export feature from module barrel...');
    await _unjectExportFeature(feature);

    onProgress('Unjecting ARB entries for feature "${feature.name}"...');
    await _unjectFeatureArb(feature);
  }

  // ===================== Generate helper =========================

  Future<void> _createFeatureDirectory(FeatureParam feature) async {
    await _directoryService.create(feature.path);
    _reportService.addCreated(feature.path);
  }

  Future<void> _createFolderStructure(FeatureParam feature) async {
    final subDirs = [
      p.join('data', 'converters'),
      p.join('data', 'datasources'),
      p.join('data', 'dtos'),
      p.join('data', 'repositories'),
      p.join('data', 'requests'),
      p.join('data', 'responses'),
      p.join('domain', 'entities'),
      p.join('domain', 'enums'),
      p.join('domain', 'params'),
      p.join('domain', 'repositories'),
      p.join('domain', 'usecases'),
      'logic',
      'ui',
    ];

    for (final sub in subDirs) {
      final path = p.join(feature.path, sub);
      await _directoryService.create(path);
      _reportService.addCreated(path);
    }
  }

  Future<void> _createFeatureBarrel(FeatureParam feature) async {
    final barrelPath = feature.featureBarrelPath;
    final content = FeatureTemplate.initialBarrelContent();
    await _fileService.writeAsString(path: barrelPath, content: content);
    _reportService.addCreated(barrelPath);
  }

  Future<void> _createRepoInterface(FeatureParam feature) async {
    final path = feature.repoInterfacePath;
    final content = RepositoryTemplate.interfaceClass(feature.name);
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);

    final barrelPath = feature.featureBarrelPath;
    final relativePath = p.relative(path, from: feature.path);
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
      checkpoint: '// domain',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _createRepoImpl(FeatureParam feature) async {
    final path = feature.repoImplPath;
    final content = RepositoryTemplate.implClass(feature.name);
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);

    final barrelPath = feature.featureBarrelPath;
    final relativePath = p.relative(path, from: feature.path);
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
      checkpoint: '// data',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _injectExportFeatureToModuleBarrel(FeatureParam feature) async {
    final barrelPath = p.join(
      feature.modulePath,
      'lib',
      '${feature.moduleName}.dart',
    );
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: [
        "export 'src/features/${feature.name}/${feature.name}_feature.dart';",
      ],
      checkpoint: '// ${feature.name}',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _injectFeatureArb(FeatureParam feature) async {
    final arbSnippet = FeatureTemplate.buildArbSnippet(feature.name);
    final arbPaths = await _arbService.getArbPaths(feature.modulePath);
    for (final arbPath in arbPaths) {
      await _arbService.injectBySnippet(
        arbPath: arbPath,
        arbSnippet: arbSnippet,
      );
      _reportService.addInjected(arbPath);
    }
  }

  // ===================== Remove helper =========================

  Future<void> _removeFeatureDirectory(FeatureParam feature) async {
    await _directoryService.delete(feature.path);
    _reportService.addRemoved(feature.path);
  }

  Future<void> _unjectExportFeature(FeatureParam feature) async {
    final barrelPath = p.join(
      feature.modulePath,
      'lib',
      '${feature.moduleName}.dart',
    );
    if (await _fileService.exists(barrelPath)) {
      await _exportService.unject(
        barrelPath: barrelPath,
        exportLines: [
          "export 'src/features/${feature.name}/${feature.name}_feature.dart';",
        ],
      );
      _reportService.addUnjected(barrelPath);
    }
  }

  Future<void> _unjectFeatureArb(FeatureParam feature) async {
    final arbPaths = await _arbService.getArbPaths(feature.modulePath);
    for (final arbPath in arbPaths) {
      await _arbService.unjectBetweenKeys(
        arbPath: arbPath,
        startKey: '@${FeatureTemplate.startDividerArbKey(feature.name)}',
        endKey: '@${FeatureTemplate.endDividerArbKey(feature.name)}',
      );
      _reportService.addUnjected(arbPath);
    }
  }
}
