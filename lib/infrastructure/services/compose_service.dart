import 'package:analyzer/dart/analysis/utilities.dart';

import '../../core/extensions/compose_form_param_x.dart';
import '../../core/extensions/compose_param_x.dart';
import '../../core/extensions/compose_retrieval_param_x.dart';
import '../../core/extensions/state_control_x.dart';
import '../../domain/enums/state_control.dart';
import '../../domain/models/dependency_metadata.dart';
import '../../domain/models/logic_metadata.dart';
import '../../domain/params/app_integration/compose_form_param.dart';
import '../../domain/params/app_integration/compose_mutation_param.dart';
import '../../domain/params/app_integration/compose_pagination_param.dart';
import '../../domain/params/app_integration/compose_retrieval_param.dart';
import '../templates/compose/compose_form_template.dart';
import '../templates/compose/compose_mutation_template.dart';
import '../templates/compose/compose_pagination_template.dart';
import '../templates/compose/compose_retrieval_template.dart';
import '../visitors/constructor_param_visitor.dart';
import '../visitors/logic_visitor.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class ComposeService {
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final FileService _fileService;

  const ComposeService({
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required FileService fileService,
  }) : _reportService = reportService,
       _directoryService = directoryService,
       _fileService = fileService;

  Future<void> composePagination({
    required ComposePaginationParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Inspecting logic flow...');
    final logicFlowMetadata = await _inspectLogicMetadata(
      param.logicFlowSlicePath,
    );

    onProgress('Generating pagination compose artifact...');
    final artifact = ComposePaginationTemplate.build(
      param: param,
      logicFlow: logicFlowMetadata,
    );
    await _fileService.writeAsString(
      path: artifact.path,
      content: artifact.content,
    );

    _reportService.addCreated(artifact.path);
  }

  Future<void> composeRetrieval({
    required ComposeRetrievalParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Inspecting logic flow...');
    final logicFlowMetadata = await _inspectLogicMetadata(
      param.logicFlowSlicePath,
    );

    onProgress('Inspecting widgets...');
    final metadatas = await _inspectWidgetMetadata(param.uiSlicePath);

    onProgress('Generating retrieval compose artifact...');
    final artifact = ComposeRetrievalTemplate.build(
      param: param,
      metadatas: metadatas,
      logicFlow: logicFlowMetadata,
    );
    await _fileService.writeAsString(
      path: artifact.path,
      content: artifact.content,
    );

    _reportService.addCreated(artifact.path);
  }

  Future<void> composeForm({
    required ComposeFormParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Inspecting logic flow...');
    final logicFlowMetadata = await _inspectLogicMetadata(
      param.logicFlowSlicePath,
    );
    onProgress('Inspecting logic...');
    final logicMetadata = await _inspectLogicMetadata(param.logicSlicePath);

    onProgress('Generating form compose artifact...');
    final artifact = ComposeFormTemplate.build(
      param: param,
      logicFlow: logicFlowMetadata,
      logic: logicMetadata,
    );
    await _fileService.writeAsString(
      path: artifact.path,
      content: artifact.content,
    );

    _reportService.addCreated(artifact.path);
  }

  Future<void> composeMutation({
    required ComposeMutationParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Inspecting logic flow...');
    final logicFlowMetadata = await _inspectLogicMetadata(
      param.logicFlowSlicePath,
    );

    onProgress('Generating mutation compose artifact...');
    final artifact = ComposeMutationTemplate.build(
      param: param,
      logicFlow: logicFlowMetadata,
    );
    await _fileService.writeAsString(
      path: artifact.path,
      content: artifact.content,
    );

    _reportService.addCreated(artifact.path);
  }

  // ====================== Helper ======================
  Future<List<DependencyMetadata>> _inspectWidgetMetadata(
    String uiSlicePath,
  ) async {
    final metadatas = <DependencyMetadata>[];
    final suffixToCheck = ['_skeleton', '_content'];
    final paths = await _directoryService.listPaths(
      dirPath: uiSlicePath,
      where: (fileSystem, isFile) =>
          isFile &&
          suffixToCheck.any((e) => fileSystem.path.endsWith('$e.dart')),
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
    );
  }
}
