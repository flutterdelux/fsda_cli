import 'package:path/path.dart' as p;

import '../../core/extensions/ds_param_x.dart';
import '../../domain/params/ds_param.dart';
import '../../domain/params/local_ds_param.dart';
import '../../domain/params/remote_ds_param.dart';
import '../templates/datasources/data_source_template.dart';
import '../templates/repositories/repository_template.dart';
import '../text_modifiers/string_extension.dart';
import 'helpers/export_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';

class DataSourceService {
  final OperationReportService _reportService;
  final ExportService _exportService;
  final FileService _fileService;
  final ImportService _importService;

  const DataSourceService({
    required OperationReportService reportService,
    required ExportService exportService,
    required FileService fileService,
    required ImportService importService,
  }) : _reportService = reportService,
       _exportService = exportService,
       _fileService = fileService,
       _importService = importService;

  Future<void> generateRemoteDataSource({
    required RemoteDsParam remoteDs,
    required Function(String) onProgress,
  }) async {
    onProgress('Creating remote data source interface...');
    await _createRemoteDsInterface(remoteDs);

    onProgress('Injecting export remote data source interface...');
    await _exportToFeatureBarrel(
      dsParam: remoteDs,
      filePath: remoteDs.interfacePath,
    );

    onProgress('Creating remote data source implementation...');
    await _createRemoteDsImpl(remoteDs);

    onProgress('Injecting export remote data source impl...');
    await _exportToFeatureBarrel(
      dsParam: remoteDs,
      filePath: remoteDs.implPath,
    );

    onProgress(
      'Injecting remote data source into repository implementation...',
    );
    await _injectToRepoImpl(remoteDs);
  }

  Future<void> generateLocalDataSource({
    required LocalDsParam localDs,
    required Function(String) onProgress,
  }) async {
    onProgress('Creating local data source interface...');
    await _createLocalDsInterface(localDs);

    onProgress('Injecting export local data source interface...');
    await _exportToFeatureBarrel(
      dsParam: localDs,
      filePath: localDs.interfacePath,
    );

    onProgress('Creating local data source implementation...');
    await _createLocalDsImpl(localDs);

    onProgress('Injecting export local data source impl...');
    await _exportToFeatureBarrel(dsParam: localDs, filePath: localDs.implPath);

    onProgress('Injecting local data source into repository implementation...');
    await _injectToRepoImpl(localDs);
  }

  // ========= Helpers ===============

  Future<void> _createRemoteDsInterface(RemoteDsParam remoteDs) async {
    final path = remoteDs.interfacePath;
    final content = DataSourceTemplate.interfaceClass(
      feature: remoteDs.featureName,
      mode: remoteDs.mode,
    );
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _createRemoteDsImpl(RemoteDsParam remoteDs) async {
    final path = remoteDs.implPath;
    final content = DataSourceTemplate.remoteImplClass(
      feature: remoteDs.featureName,
      basePath: remoteDs.basePath,
    );
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _createLocalDsInterface(LocalDsParam localDs) async {
    final path = localDs.interfacePath;
    final content = DataSourceTemplate.interfaceClass(
      feature: localDs.featureName,
      mode: localDs.mode,
    );
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _createLocalDsImpl(LocalDsParam localDs) async {
    final path = localDs.implPath;
    final content = DataSourceTemplate.localImplClass(
      feature: localDs.featureName,
      cacheKey: localDs.cacheKey,
    );
    await _fileService.writeAsString(path: path, content: content);
    _reportService.addCreated(path);
  }

  Future<void> _exportToFeatureBarrel({
    required DsParam dsParam,
    required String filePath,
  }) async {
    final barrelPath = dsParam.featureBarrelPath;
    final relativePath = p.relative(filePath, from: dsParam.featurePath);
    await _exportService.inject(
      barrelPath: barrelPath,
      exportLines: ["export '${relativePath.replaceAll(r'\', '/')}';"],
      checkpoint: '// data',
    );
    _reportService.addInjected(barrelPath);
  }

  Future<void> _injectToRepoImpl(DsParam dsParam) async {
    final path = p.join(
      dsParam.featurePath,
      'data',
      'repositories',
      '${dsParam.featureName}_repository_impl.dart',
    );

    if (!await _fileService.exists(path)) return;

    String content = await _fileService.readAsString(path);

    final featurePascal = dsParam.featureName.pascalCase;
    final featureCamel = dsParam.featureName.camelCase;

    final fieldName = dsParam.mode == .remote
        ? '_remoteDataSource'
        : '_localDataSource';

    final typeName = dsParam.mode == .remote
        ? '${featurePascal}RemoteDataSource'
        : '${featurePascal}LocalDataSource';
    final paramName = dsParam.mode == .remote
        ? '${featureCamel}RemoteDataSource'
        : '${featureCamel}LocalDataSource';

    if (content.contains(typeName)) return;

    // 1. Inject Field setelah tanda [DS_FIELD]
    if (content.contains(RepositoryTemplate.markDsField)) {
      final fieldCode = '  final $typeName $fieldName;';
      content = content.replaceFirst(
        RepositoryTemplate.markDsField,
        '${RepositoryTemplate.markDsField}\n$fieldCode',
      );
    }

    // 2. Inject Parameter konstruktor setelah tanda [DS_PARAM]
    if (content.contains(RepositoryTemplate.markDsParam)) {
      final paramCode = '    required $typeName $paramName,';
      content = content.replaceFirst(
        RepositoryTemplate.markDsParam,
        '${RepositoryTemplate.markDsParam}\n$paramCode',
      );
    }

    // 3. Inject Initializer setelah tanda [DS_INIT]
    if (content.contains(RepositoryTemplate.markDsInit)) {
      final initCode = '       $fieldName = $paramName,';
      content = content.replaceFirst(
        RepositoryTemplate.markDsInit,
        '${RepositoryTemplate.markDsInit}\n$initCode',
      );
    }

    await _fileService.writeAsString(path: path, content: content);

    final relativePath = p.relative(
      dsParam.interfacePath,
      from: p.dirname(path),
    );
    final imports = {"import '${relativePath.replaceAll(r'\', '/')}';"};
    await _importService.injectImport(path: path, imports: imports);

    _reportService.addInjected(path);
  }
}
