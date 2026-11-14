import '../../core/extensions/ds_param_x.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../domain/params/remote_ds_param.dart';
import '../../infrastructure/services/data_source_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import 'wrapper/feature_gate_command.dart';

class DsRemoteCommand extends FeatureGateCommand {
  final DataSourceService _dsService;
  final FileService _fileService;

  DsRemoteCommand({
    required DataSourceService dataSourceService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _dsService = dataSourceService,
       _fileService = fileService;

  @override
  String get name => 'ds-remote';

  @override
  String get description =>
      'Generates a remote data source interface and implementation for a feature.';

  @override
  String get invocation => 'fsda $name "<base-path>" -f <feature> -m <module>';

  @override
  Future<int> handleFeatureGate(FeatureGateParam param) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Base path argument is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid base path: "$rest".');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final basePath = rest.first;

    final dsParam = RemoteDsParam(
      featureName: param.featureName,
      featurePath: param.featurePath,
      moduleName: param.moduleName,
      modulePath: param.modulePath,
      basePath: basePath,
    );

    if (await _fileService.exists(dsParam.interfacePath)) {
      logger.error(
        'Remote data source interface already exists at ${dsParam.interfacePath}',
      );
      return errorUsage;
    }

    if (await _fileService.exists(dsParam.implPath)) {
      logger.error(
        'Remote data source implementation already exists at ${dsParam.implPath}',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating remote data source for feature "${param.featureName}" (${param.moduleName})...',
    );

    try {
      await _dsService.generateRemoteDataSource(
        remoteDs: dsParam,
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Remote Data Source Generation Summary',
      );

      progress.complete(
        'Remote data source successfully generated for feature "${param.featureName}" (${param.moduleName})!',
      );

      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate remote data source: $e');
      return errorSystem;
    }
  }
}
