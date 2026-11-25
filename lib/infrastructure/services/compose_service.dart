import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../core/extensions/compose_param_x.dart';
import '../../core/extensions/feature_param_x.dart';
import '../../core/extensions/logic_metadata_x.dart';
import '../../core/extensions/module_param_x.dart';
import '../../core/extensions/reg_module_param_x.dart';
import '../../core/extensions/state_control_x.dart';
import '../../domain/enums/compose_type.dart';
import '../../domain/enums/state_control.dart';
import '../../domain/models/artifact_generation_model.dart';
import '../../domain/models/dependency_metadata.dart';
import '../../domain/models/logic_metadata.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/app_integration/compose_param.dart';
import '../templates/app_integration/compose_route_template.dart';
import '../templates/compose_target/compose_form_template.dart';
import '../templates/compose_target/compose_mutation_template.dart';
import '../templates/compose_target/compose_pagination_template.dart';
import '../templates/compose_target/compose_retrieval_template.dart';
import '../text_modifiers/string_extension.dart';
import '../visitors/constructor_param_visitor.dart';
import '../visitors/logic_visitor.dart';
import '../visitors/module_route_visitor.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_finder_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';
import 'model_service.dart';

class ComposeService {
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final FileService _fileService;
  final FileFinderService _fileFinderService;
  final ModelService _modelService;
  final ImportService _importService;

  const ComposeService({
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required FileService fileService,
    required FileFinderService fileFinderService,
    required ModelService modelService,
    required ImportService importService,
  }) : _reportService = reportService,
       _directoryService = directoryService,
       _fileService = fileService,
       _fileFinderService = fileFinderService,
       _modelService = modelService,
       _importService = importService;

  Future<void> compose({
    required ComposeParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Inspecting logic flow...');
    final logicFlowMetadata = await _inspectLogicMetadata(
      param.logicFlowSlicePath,
    );

    onProgress('Inspecting external params...');
    final constructorProps = await _inspectExternalProps(
      externalParam: logicFlowMetadata.externalParam,
      modulePath: param.modulePath,
    );
    final methodProps = await _inspectExternalProps(
      externalParam: logicFlowMetadata.methodExternalParam,
      modulePath: param.modulePath,
    );

    final ArtifactGenerationModel artifact;

    switch (param.type) {
      case ComposeType.mutation:
        onProgress('Generating mutation compose artifact...');
        artifact = ComposeMutationTemplate.build(
          param: param,
          logicFlow: logicFlowMetadata,
          constructorProps: constructorProps,
          methodProps: methodProps,
        );
        break;

      case ComposeType.retrieval:
        onProgress('Inspecting widgets...');
        final uiMetadatas = await _inspectWidgetMetadata(
          uiSlicePath: param.uiSlicePath,
          suffixes: ['_skeleton', '_content'],
        );

        onProgress('Generating retrieval compose artifact...');
        artifact = ComposeRetrievalTemplate.build(
          param: param,
          uiMetadatas: uiMetadatas,
          logicFlow: logicFlowMetadata,
          constructorProps: constructorProps,
          methodProps: methodProps,
        );
        break;

      case ComposeType.pagination:
        onProgress('Generating pagination compose artifact...');
        artifact = ComposePaginationTemplate.build(
          param: param,
          logicFlow: logicFlowMetadata,
        );
        break;
      case ComposeType.form:
        onProgress('Inspecting widgets...');
        final formSlice = param.uiSlice!;
        final uiMetadatas = await _inspectWidgetMetadata(
          uiSlicePath: param.uiSlicePath,
          suffixes: [formSlice],
        );

        final formMetadata = uiMetadatas.firstWhereOrNull(
          (e) => e.className.endsWith(formSlice.pascalCase),
        );
        final initialDataParam = formMetadata?.parameters.firstWhereOrNull(
          (p) => p.name == 'initialData',
        );

        final initialProps = await _inspectExternalProps(
          externalParam: initialDataParam,
          modulePath: param.modulePath,
        );

        onProgress('Inspecting logic...');
        final logicMetadata = await _inspectLogicMetadata(param.logicSlicePath);

        onProgress('Generating form compose artifact...');
        artifact = ComposeFormTemplate.build(
          param: param,
          logicFlow: logicFlowMetadata,
          logic: logicMetadata,
          initialDataType: initialDataParam?.type,
          initialProps: initialProps,
        );
        break;
    }

    await _fileService.writeAsString(
      path: artifact.path,
      content: artifact.content,
    );

    _reportService.addCreated(artifact.path);

    if (param.withRoute && param.target.endsWith('_page')) {
      onProgress('Injecting route target...');
      final targetProps = await _inspectTargetWidgetProps(artifact.path);
      await _injectRouteTarget(param: param, props: targetProps);
    }
  }

  // ====================== Helper ======================
  Future<List<DependencyMetadata>> _inspectWidgetMetadata({
    required String uiSlicePath,
    required List<String> suffixes,
  }) async {
    final metadatas = <DependencyMetadata>[];
    final paths = await _directoryService.listPaths(
      dirPath: uiSlicePath,
      where: (fileSystem, isFile) =>
          isFile && suffixes.any((e) => fileSystem.path.endsWith('$e.dart')),
    );

    for (final artifactPath in paths) {
      final contentString = await _fileService.readAsString(artifactPath);
      final unit = parseString(content: contentString).unit;

      final visitor = ConstructorParamVisitor();
      unit.visitChildren(visitor);

      if (visitor.className != null) {
        metadatas.add(
          DependencyMetadata(
            className: visitor.className!,
            parameters: visitor.parameters,
          ),
        );
      }
    }

    return metadatas;
  }

  Future<LogicMetadata> _inspectLogicMetadata(String logicSlicePath) async {
    final logicSuffixs = StateControl.values.map((e) => e.suffix);
    final paths = await _directoryService.listPaths(
      dirPath: logicSlicePath,
      where: (fileSystem, isFile) {
        return isFile &&
            logicSuffixs.any(
              (suffix) => fileSystem.path.endsWith('_$suffix.dart'),
            );
      },
    );

    if (paths.isEmpty) {
      throw Exception('Logic file not found in $logicSlicePath');
    }

    final contentString = await _fileService.readAsString(paths.first);
    final unit = parseString(content: contentString).unit;

    final visitor = LogicVisitor();
    unit.visitChildren(visitor);

    if (visitor.className == null || visitor.extendsClass == null) {
      throw Exception('Failed to extract Logic class metadata.');
    }

    final control = StateControl.parseFromExtends(visitor.extendsClass!);
    if (control == null) {
      throw Exception('Logic not found.');
    }

    return LogicMetadata(
      className: visitor.className!,
      parameters: visitor.parameters,
      control: control,
      method: visitor.method ?? '',
      methodParameters: visitor.methodParameters,
    );
  }

  Future<List<PropModel>> _inspectTargetWidgetProps(String artifactPath) async {
    final content = await _fileService.readAsString(artifactPath);
    final unit = parseString(content: content).unit;

    final visitor = ConstructorParamVisitor();
    unit.visitChildren(visitor);

    return visitor.parameters
        .where((p) => p.name != 'key')
        .map(
          (p) => PropModel(
            name: p.name,
            type: p.type,
            defaultValue: p.defaultValue ?? '',
            converter: '',
          ),
        )
        .toList();
  }

  Future<List<PropModel>> _inspectExternalProps({
    required DependencyParamMetadata? externalParam,
    required String modulePath,
  }) async {
    if (externalParam == null) return [];
    final modelPath = await _fileFinderService.findFile(
      rawRef: externalParam.type,
      modulePath: modulePath,
    );
    if (modelPath == null) return [];
    return _modelService.getPropsFromModelFile(modelPath);
  }

  Future<void> _injectRouteTarget({
    required ComposeParam param,
    required List<PropModel> props,
  }) async {
    final path = param.appModuleRoutePath;
    if (!await _fileService.exists(path)) {
      _reportService.addSkipped(path);
      return;
    }

    String content = await _fileService.readAsString(path);
    final routeConstName = '_${param.targetBaseName.camelCase}';
    final navMethodName = 'to${param.targetBaseName.pascalCase}';

    if (content.contains('name: $routeConstName') ||
        content.contains('static Future<dynamic> $navMethodName(')) {
      _reportService.addSkipped(path);
      return;
    }

    final routeClassName = '${param.modulePascal}Route';
    final featureBaseGetterName = '${param.featureCamel}Base';

    // A. Inject konstanta rute di awal body class <Module>Route
    final constantVisitor = ModuleRouteVisitor(
      routeClassName: routeClassName,
      featureBaseGetterName: featureBaseGetterName,
    );
    parseString(content: content).unit.visitChildren(constantVisitor);
    if (constantVisitor.classBodyOffset != null) {
      content = _insertAt(
        content,
        constantVisitor.classBodyOffset!,
        '\n${ComposeRouteTemplate.buildConstant(param)}',
      );
    }

    // B. Inject GoRoute ke dalam ListLiteral `routes: [...]` pada getter <feature>Base
    final routeVisitor = ModuleRouteVisitor(
      routeClassName: routeClassName,
      featureBaseGetterName: featureBaseGetterName,
    );
    parseString(content: content).unit.visitChildren(routeVisitor);
    if (routeVisitor.routesInsertOffset != null) {
      final routeItemCode = ComposeRouteTemplate.buildRoute(
        param: param,
        props: props,
      ).trimRight();
      final injectedRoute = routeVisitor.routesIsEmpty
          ? '\n$routeItemCode\n        '
          : ',\n$routeItemCode';
      content = _insertAt(
        content,
        routeVisitor.routesInsertOffset!,
        injectedRoute,
      );
    }

    // C. Inject static method navigasi di akhir body class <Module>Route
    final navigationVisitor = ModuleRouteVisitor(
      routeClassName: routeClassName,
      featureBaseGetterName: featureBaseGetterName,
    );
    parseString(content: content).unit.visitChildren(navigationVisitor);
    if (navigationVisitor.classEndOffset != null) {
      final navCode =
          '\n${ComposeRouteTemplate.buildNavigation(param: param, props: props).trimRight()}\n';
      content = _insertAt(content, navigationVisitor.classEndOffset!, navCode);
    }

    await _fileService.writeAsString(path: path, content: content);

    await _importService.injectImport(
      path: path,
      imports: {
        "import '${p.relative(param.targetPath, from: p.dirname(path))}';",
      },
    );
    _reportService.addInjected(path);
  }

  String _insertAt(String source, int offset, String insertion) {
    return '${source.substring(0, offset)}$insertion${source.substring(offset)}';
  }
}
