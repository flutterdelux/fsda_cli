import 'package:path/path.dart' as p;

import '../../core/extensions/feature_param_x.dart';
import '../../core/extensions/flow_type_x.dart';
import '../../core/extensions/module_param_x.dart';
import '../../core/extensions/sequence_param_x.dart';
import '../../domain/enums/ds_mode.dart';
import '../../domain/params/sequence_param.dart';
import '../templates/datasources/data_source_template.dart';
import '../templates/datasources/local_ds_body_template.dart';
import '../templates/datasources/remote_ds_body_template.dart';
import '../templates/feature_template.dart';
import '../templates/repositories/repo_body_template.dart';
import '../templates/repositories/repository_template.dart';
import '../templates/use_case_template.dart';
import 'helpers/arb_service.dart';
import 'helpers/export_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_resolver_service.dart';
import 'helpers/import_service.dart';
import 'helpers/method_service.dart';
import 'helpers/operation_report_service.dart';

class SequenceService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final ArbService _arbService;
  final ExportService _exportService;
  final MethodService _methodService;
  final ImportService _importService;
  final ImportResolverService _importResolverService;

  const SequenceService({
    required OperationReportService reportService,
    required FileService fileService,
    required ArbService arbService,
    required ExportService exportService,
    required MethodService methodService,
    required ImportService importService,
    required ImportResolverService importResolverService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _arbService = arbService,
       _exportService = exportService,
       _methodService = methodService,
       _importService = importService,
       _importResolverService = importResolverService;

  Future<void> generate({
    required SequenceParam sequence,
    required void Function(String) onProgress,
  }) async {
    onProgress('Injecting method to datasource interface...');
    await _injectMethodToDsInterface(sequence);

    onProgress('Injecting import model to datasource interface...');
    await _injectImportToDsInterface(sequence);

    onProgress('Injecting method to datasource implementation...');
    await _injectMethodToDsImpl(sequence);

    onProgress('Injecting import model to datasource implementation...');
    await _injectImportToDsImpl(sequence);

    onProgress('Injecting method to repository interface...');
    await _injectMethodToRepoInterface(sequence);

    onProgress('Injecting import model to repository interface...');
    await _injectImportToRepoInterface(sequence);

    onProgress('Injecting method to repository implementation...');
    await _injectMethodToRepoImpl(sequence);

    onProgress('Injecting import model to repository implementation...');
    await _injectImportToRepoImpl(sequence);

    onProgress('Creating use case and injecting export to feature barrel...');
    await _createUseCaseAndExport(sequence);

    onProgress('Injecting import to use case...');
    await _injectImportToUseCase(sequence);

    onProgress('Injecting use case localization...');
    await _injectUseCaseArb(sequence);
  }

  Future<void> remove({
    required SequenceParam sequence,
    required void Function(String) onProgress,
  }) async {
    onProgress('Unjecting method from datasource interface...');
    await _methodService.unjectFromClass(
      path: sequence.dsInterfacePath,
      methodName: sequence.method,
    );
    _reportService.addUnjected(sequence.dsInterfacePath);

    onProgress('Unjecting method from datasource implementation...');
    await _methodService.unjectFromClass(
      path: sequence.dsImplPath,
      methodName: sequence.method,
    );
    _reportService.addUnjected(sequence.dsImplPath);

    onProgress('Unjecting method from repository interface...');
    await _methodService.unjectFromClass(
      path: sequence.repoInterfacePath,
      methodName: sequence.method,
    );
    _reportService.addUnjected(sequence.repoInterfacePath);

    onProgress('Unjecting method from repository implementation...');
    await _methodService.unjectFromClass(
      path: sequence.repoImplPath,
      methodName: sequence.method,
    );
    _reportService.addUnjected(sequence.repoImplPath);

    onProgress('Removing use case file and unjecting barrel export...');
    await _removeUseCaseAndUnjectExport(sequence);

    onProgress('Unjecting localization entries...');
    await _unjectUseCaseArb(sequence);
  }

  // ====================== Generation Helper ======================

  // --- Data Source Interface ---
  Future<void> _injectMethodToDsInterface(SequenceParam sequence) async {
    final path = sequence.dsInterfacePath;
    final methodCode = DataSourceTemplate.interfaceMethod(sequence);
    await _methodService.injectToClass(path: path, methodCode: methodCode);
    _reportService.addInjected(path);
  }

  Future<void> _injectImportToDsInterface(SequenceParam sequence) async {
    final path = sequence.dsInterfacePath;
    final imports = await _importResolverService.resolve(
      rawTypes: {
        ?sequence.dtoPascal,
        ?sequence.requestPascal,
        ?sequence.flow.returnType,
      },
      targetFilePath: path,
      modulePath: sequence.modulePath,
    );

    await _importService.injectImport(path: path, imports: imports);
    _reportService.addInjected(path);
  }

  // --- Data Source Implementation ---
  Future<void> _injectMethodToDsImpl(SequenceParam sequence) async {
    final path = sequence.dsImplPath;

    final methodBody = sequence.dsMode == DsMode.remote
        ? RemoteDsBodyTemplate.build(sequence)
        : LocalDsBodyTemplate.build(sequence);

    final methodContent = DataSourceTemplate.implMethod(
      sequence: sequence,
      body: methodBody,
    );
    await _methodService.injectToClass(path: path, methodCode: methodContent);
    _reportService.addInjected(path);
  }

  Future<void> _injectImportToDsImpl(SequenceParam sequence) async {
    final path = sequence.dsImplPath;
    final imports = await _importResolverService.resolve(
      rawTypes: {
        ?sequence.dtoPascal,
        ?sequence.requestPascal,
        ?sequence.responsePascal,
        ?sequence.flow.returnType,
        '${sequence.modulePascal}Exception',
      },
      targetFilePath: path,
      modulePath: sequence.modulePath,
    );

    await _importService.injectImport(path: path, imports: imports);
    _reportService.addInjected(path);
  }

  // --- Repository Interface ---
  Future<void> _injectMethodToRepoInterface(SequenceParam sequence) async {
    final path = sequence.repoInterfacePath;
    final methodCode = RepositoryTemplate.interfaceMethod(sequence);
    await _methodService.injectToClass(path: path, methodCode: methodCode);
    _reportService.addInjected(path);
  }

  Future<void> _injectImportToRepoInterface(SequenceParam sequence) async {
    final path = sequence.repoInterfacePath;
    final imports = await _importResolverService.resolve(
      rawTypes: {
        ?sequence.entityPascal,
        ?sequence.paramPascal,
        sequence.flow.resultType,
      },
      targetFilePath: path,
      modulePath: sequence.modulePath,
    );

    await _importService.injectImport(path: path, imports: imports);
    _reportService.addInjected(path);
  }

  // --- Repository Implementation ---
  Future<void> _injectMethodToRepoImpl(SequenceParam sequence) async {
    final path = sequence.repoImplPath;
    final methodBody = RepoBodyTemplate.build(sequence);
    final methodCode = RepositoryTemplate.implMethod(
      sequence: sequence,
      body: methodBody,
    );

    await _methodService.injectToClass(path: path, methodCode: methodCode);
    _reportService.addInjected(path);
  }

  Future<void> _injectImportToRepoImpl(SequenceParam sequence) async {
    final path = sequence.repoImplPath;
    final imports = await _importResolverService.resolve(
      rawTypes: {
        ?sequence.entityPascal,
        ?sequence.paramPascal,
        ?sequence.dtoPascal,
        ?sequence.requestPascal,
        sequence.flow.resultType,
      },
      targetFilePath: path,
      modulePath: sequence.modulePath,
    );

    await _importService.injectImport(path: path, imports: imports);
    _reportService.addInjected(path);
  }

  // --- Use Case ---
  Future<void> _createUseCaseAndExport(SequenceParam sequence) async {
    final path = sequence.ucPath;

    final content = UseCaseTemplate.build(sequence: sequence);
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);

    final barrelPath = sequence.featureBarrelPath;
    final relativePath = p.relative(path, from: sequence.featurePath);
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
      checkpoint: '// domain',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _injectImportToUseCase(SequenceParam sequence) async {
    final path = sequence.ucPath;
    final imports = await _importResolverService.resolve(
      rawTypes: {?sequence.entityPascal, ?sequence.paramPascal},
      targetFilePath: path,
      modulePath: sequence.modulePath,
    );

    await _importService.injectImport(path: path, imports: imports);
    _reportService.addInjected(path);
  }

  Future<void> _injectUseCaseArb(SequenceParam sequence) async {
    final arbPaths = await _arbService.getArbPaths(sequence.modulePath);
    final arbEntries = UseCaseTemplate.buildArbEntries(sequence);
    final endKey = FeatureTemplate.endDividerArbKey(sequence.featureName);

    for (final arbPath in arbPaths) {
      await _arbService.injectEntriesBeforeKey(
        arbPath: arbPath,
        arbEntries: arbEntries,
        endKey: endKey,
      );
    }
  }

  // =========== Remove Helper =================

  Future<void> _removeUseCaseAndUnjectExport(SequenceParam sequence) async {
    final path = sequence.ucPath;
    if (await _fileService.exists(path)) {
      await _fileService.delete(path);
      _reportService.addRemoved(path);
    }

    final barrelPath = sequence.featureBarrelPath;
    final relativePath = p.relative(path, from: sequence.featurePath);
    await _exportService.unject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
    );
    _reportService.addUnjected(barrelPath);
  }

  Future<void> _unjectUseCaseArb(SequenceParam sequence) async {
    final arbPaths = await _arbService.getArbPaths(sequence.modulePath);
    final arbEntries = UseCaseTemplate.buildArbEntries(sequence);

    for (final arbPath in arbPaths) {
      await _arbService.unjectEntries(arbPath: arbPath, arbEntries: arbEntries);
      _reportService.addUnjected(arbPath);
    }
  }
}
