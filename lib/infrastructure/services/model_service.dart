import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;

import '../../core/extensions/feature_gate_param_x.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/model_param.dart';
import '../templates/feature_template.dart';
import '../templates/model_template.dart';
import '../visitors/model_visitor.dart';
import 'helpers/arb_service.dart';
import 'helpers/export_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_resolver_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';

class ModelService {
  final OperationReportService _reportService;
  final ExportService _exportService;
  final ArbService _arbService;
  final FileService _fileService;
  final ImportResolverService _importResolverService;
  final ImportService _importService;

  const ModelService({
    required OperationReportService reportService,
    required ExportService exportService,
    required ArbService arbService,
    required FileService fileService,
    required ImportResolverService importResolverService,
    required ImportService importService,
  }) : _reportService = reportService,
       _exportService = exportService,
       _arbService = arbService,
       _fileService = fileService,
       _importResolverService = importResolverService,
       _importService = importService;

  Future<void> generateModel({
    required ModelParam model,
    required Function(String) onProgress,
  }) async {
    onProgress('Creating model file...');
    await _createModel(model);

    onProgress('Injecting import for class that use in model...');
    await _injectImportForModel(model);

    if (model.type case .entity || .param) {
      onProgress('Injecting export model to feature barrel...');
      await _exportModel(model);
    }

    if (model.isInjectL10n && model.type == .entity) {
      onProgress('Injecting localization keys into ARB files...');
      await _injectModelArb(model);
    }
  }

  Future<void> removeModel({
    required ModelParam model,
    required Function(String) onProgress,
  }) async {
    onProgress('Removing model file...');
    await _removeModel(model);

    if (model.type case .entity || .param) {
      onProgress('Unjecting export model from feature barrel...');
      await _unjectExportModel(model);
    }

    if (model.type case .entity) {
      onProgress('Unjecting localization model...');
      await _unjectArbModel(model);
    }
  }

  Future<List<PropModel>> getPropsFromModelFile(String modelPath) async {
    if (!await _fileService.exists(modelPath)) return [];

    try {
      final content = await _fileService.readAsString(modelPath);
      final result = parseString(content: content);

      final visitor = ModelVisitor();
      result.unit.accept(visitor);

      return visitor.props;
    } catch (_) {
      return [];
    }
  }

  // ==================== Generation Helper ====================

  Future<void> _createModel(ModelParam model) async {
    final content = switch (model.type) {
      .entity => ModelTemplate.buildEntity(model),
      .param => ModelTemplate.buildParam(model),
      .dto => ModelTemplate.buildDto(model),
      .request => ModelTemplate.buildRequest(model),
      .response => ModelTemplate.buildResponse(model),
    };

    final path = model.path;
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _injectImportForModel(ModelParam model) async {
    final rawTypes = <String>{
      ...model.props.map((e) => e.type),
      ...model.props.map((e) => e.converter).where((c) => c.isNotEmpty),
    };
    final imports = await _importResolverService.resolve(
      rawTypes: rawTypes,
      targetFilePath: model.path,
      featurePath: model.featurePath,
    );
    await _importService.injectImport(path: model.path, imports: imports);
  }

  Future<void> _exportModel(ModelParam model) async {
    final barrelPath = model.featureBarrelPath;
    if (!await _fileService.exists(barrelPath)) return;
    final relativePath = p.relative(model.path, from: model.featurePath);
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
      checkpoint: '// domain',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _injectModelArb(ModelParam model) async {
    final arbPaths = await _arbService.getArbPaths(model.modulePath);
    final arbEntries = ModelTemplate.buildArbEntries(model);
    final endKey = FeatureTemplate.endDividerArbKey(model.featureName);
    for (final arbPath in arbPaths) {
      await _arbService.injectEntriesBeforeKey(
        arbPath: arbPath,
        arbEntries: arbEntries,
        endKey: endKey,
      );
      _reportService.addInjected(arbPath);
    }
  }

  // ===================== Remove Helper =========================

  Future<void> _removeModel(ModelParam model) async {
    final basePath = model.path;
    if (await _fileService.exists(basePath)) {
      await _fileService.delete(basePath);
      _reportService.addRemoved(model.path);
    }

    // Also delete generated files
    final generatedSuffixs = ['.freezed.dart', '.g.dart'];
    for (final suffix in generatedSuffixs) {
      final path = basePath.replaceAll('.dart', suffix);
      if (await _fileService.exists(path)) {
        await _fileService.delete(path);
      }
    }
  }

  Future<void> _unjectExportModel(ModelParam model) async {
    final barrelPath = model.featureBarrelPath;
    final relativePath = p.relative(model.path, from: model.featurePath);
    await _exportService.unject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
    );
    _reportService.addUnjected(barrelPath);
  }

  Future<void> _unjectArbModel(ModelParam model) async {
    final arbPaths = await _arbService.getArbPaths(model.modulePath);
    final arbEntries = ModelTemplate.buildArbEntries(model);
    for (final arbPath in arbPaths) {
      await _arbService.unjectEntries(arbPath: arbPath, arbEntries: arbEntries);
      _reportService.addUnjected(arbPath);
    }
  }
}
