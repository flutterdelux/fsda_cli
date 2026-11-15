import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;

import '../../core/extensions/feature_gate_param_x.dart';
import '../../domain/models/artifact_generation_model.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/slice_gate_param.dart';
import '../../domain/params/ui/ui_form_param.dart';
import '../../domain/params/ui/ui_lsh_param.dart';
import '../../domain/params/ui/ui_lsv_param.dart';
import '../../domain/params/ui/ui_pag_param.dart';
import '../../domain/params/ui/ui_param.dart';
import '../templates/feature_template.dart';
import '../templates/ui/ui_form_template.dart';
import '../templates/ui/ui_lsh_template.dart';
import '../templates/ui/ui_lsv_template.dart';
import '../templates/ui/ui_pag_template.dart';
import '../templates/ui/ui_template.dart';
import '../visitors/model_visitor.dart';
import 'helpers/arb_service.dart';
import 'helpers/export_service.dart';
import 'helpers/file_finder_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_resolver_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';

class UiService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final ArbService _arbService;
  final FileFinderService _fileFinderService;
  final ImportResolverService _importResolverService;
  final ImportService _importService;
  final ExportService _exportService;

  const UiService({
    required OperationReportService reportService,
    required FileService fileService,
    required ArbService arbService,
    required FileFinderService fileFinderService,
    required ImportResolverService importResolverService,
    required ImportService importService,
    required ExportService exportService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _arbService = arbService,
       _fileFinderService = fileFinderService,
       _importResolverService = importResolverService,
       _importService = importService,
       _exportService = exportService;

  Future<void> generate({
    required UiParam ui,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Inspecting model props...');
    final props = await _getPropsFromModelFile(
      model: ui.model,
      modulePath: ui.modulePath,
    );

    final variants = [
      UiTemplate.buildContent(ui: ui, props: props),
      UiTemplate.buildSkeleton(ui: ui, props: props),
      UiTemplate.buildErrorFeedback(ui),
    ];

    onProgress('Generating widget variants...');
    await _generateFiles(param: ui, variants: variants);

    onProgress('Injecting export widget variants...');
    await _injectExportWidgetVariants(param: ui, variants: variants);

    onProgress('Injecting localization entries...');
    final arbEntries = UiTemplate.buildArbEntries(ui);
    await _injectArbEntries(param: ui, arbEntries: arbEntries);
  }

  Future<void> generateLsv({
    required UiLsvParam ui,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Inspecting model props...');
    final props = await _getPropsFromModelFile(
      model: ui.model,
      modulePath: ui.modulePath,
    );

    final variants = [
      UiLsvTemplate.buildItem(ui: ui, props: props),
      UiLsvTemplate.buildItemSkeleton(ui),
      UiLsvTemplate.buildContent(ui),
      UiLsvTemplate.buildSkeleton(ui),
      UiLsvTemplate.buildErrorFeedback(ui),
      UiLsvTemplate.buildEmptyFeedback(ui),
    ];

    onProgress('Generating ListView widget variants...');
    await _generateFiles(param: ui, variants: variants);

    onProgress('Injecting export widget variants...');
    await _injectExportWidgetVariants(param: ui, variants: variants);

    onProgress('Injecting localization entries...');
    final arbEntries = UiLsvTemplate.buildArbEntries(ui);
    await _injectArbEntries(param: ui, arbEntries: arbEntries);
  }

  Future<void> generateLsh({
    required UiLshParam ui,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Inspecting model props...');
    final props = await _getPropsFromModelFile(
      model: ui.model,
      modulePath: ui.modulePath,
    );

    final variants = [
      UiLshTemplate.buildItem(ui: ui, props: props),
      UiLshTemplate.buildItemSkeleton(ui),
      UiLshTemplate.buildContent(ui),
      UiLshTemplate.buildSkeleton(ui),
      UiLshTemplate.buildErrorFeedback(ui),
      UiLshTemplate.buildEmptyFeedback(ui),
    ];

    onProgress('Generating Horizontal ListView widget variants...');
    await _generateFiles(param: ui, variants: variants);

    onProgress('Injecting export widget variants...');
    await _injectExportWidgetVariants(param: ui, variants: variants);

    onProgress('Injecting localization entries...');
    final arbEntries = UiLshTemplate.buildArbEntries(ui);
    await _injectArbEntries(param: ui, arbEntries: arbEntries);
  }

  Future<void> generatePag({
    required UiPagParam ui,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Inspecting model props...');
    final props = await _getPropsFromModelFile(
      model: ui.model,
      modulePath: ui.modulePath,
    );

    final variants = [
      UiPagTemplate.buildItem(ui: ui, props: props),
      UiPagTemplate.buildItemSkeleton(ui),
      UiPagTemplate.buildContent(ui),
      UiPagTemplate.buildSkeleton(ui),
      UiPagTemplate.buildErrorFeedback(ui),
      UiPagTemplate.buildEmptyFeedback(ui),
    ];

    onProgress('Generating Paginated ListView widget variants...');
    await _generateFiles(param: ui, variants: variants);

    onProgress('Injecting export widget variants...');
    await _injectExportWidgetVariants(param: ui, variants: variants);

    onProgress('Injecting localization entries...');
    final arbEntries = UiPagTemplate.buildArbEntries(ui);
    await _injectArbEntries(param: ui, arbEntries: arbEntries);
  }

  Future<void> generateForm({
    required UiFormParam ui,
    required void Function(String msg) onProgress,
  }) async {
    onProgress('Inspecting model props...');
    final props = await _getPropsFromModelFile(
      model: ui.model,
      modulePath: ui.modulePath,
    );

    final variants = [UiFormTemplate.build(ui: ui, props: props)];

    onProgress('Generating UI Form widget...');
    await _generateFiles(param: ui, variants: variants);

    onProgress('Injecting export widget variants...');
    await _injectExportWidgetVariants(param: ui, variants: variants);

    onProgress('Injecting localization entries...');
    final arbEntries = UiFormTemplate.buildArbEntries(ui);
    await _injectArbEntries(param: ui, arbEntries: arbEntries);
  }

  // =========== generation helpers ===========

  Future<void> _generateFiles({
    required SliceGateParam param,
    required List<ArtifactGenerationModel> variants,
  }) async {
    for (final artifact in variants) {
      final path = artifact.path;
      final content = artifact.content;
      await _fileService.writeAsString(path: path, content: content);

      if (artifact.typesToImport.isNotEmpty) {
        final imports = await _importResolverService.resolve(
          rawTypes: artifact.typesToImport,
          targetFilePath: path,
          modulePath: param.modulePath,
        );
        await _importService.injectImport(path: path, imports: imports);
      }

      _reportService.addCreated(path);
    }
  }

  Future<void> _injectExportWidgetVariants({
    required SliceGateParam param,
    required List<ArtifactGenerationModel> variants,
  }) async {
    final exportLines = variants.where((e) => e.needToExport).map((e) {
      final relativePath = p.relative(e.path, from: param.featurePath);
      return "export '${relativePath.replaceAll(r'\', '/')}';";
    }).toList();
    await _exportService.inject(
      barrelPath: param.featureBarrelPath,
      exportLines: exportLines,
      checkpoint: '// ui',
    );
    _reportService.addInjected(param.featureBarrelPath);
  }

  Future<void> _injectArbEntries({
    required SliceGateParam param,
    required Map<String, dynamic> arbEntries,
  }) async {
    final endKey = FeatureTemplate.endDividerArbKey(param.featureName);
    if (arbEntries.isNotEmpty) {
      final arbPaths = await _arbService.getArbPaths(param.modulePath);
      for (final path in arbPaths) {
        await _arbService.injectEntriesBeforeKey(
          arbPath: path,
          endKey: endKey,
          arbEntries: arbEntries,
        );
        _reportService.addInjected(path);
      }
    }
  }

  Future<List<PropModel>> _getPropsFromModelFile({
    required String model,
    required String modulePath,
  }) async {
    final path = await _fileFinderService.findFile(
      rawRef: model,
      modulePath: modulePath,
    );
    if (path == null) return [];
    if (!await _fileService.exists(path)) return [];

    try {
      final content = await _fileService.readAsString(path);
      final result = parseString(content: content);

      final visitor = ModelVisitor();
      result.unit.accept(visitor);

      return visitor.props;
    } catch (_) {
      return [];
    }
  }
}
