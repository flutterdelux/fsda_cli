import '../../core/constants/rules.dart';
import '../../core/extensions/ds_param_x.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../domain/params/local_ds_param.dart';
import '../../infrastructure/services/data_source_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import 'wrapper/feature_gate_command.dart';

class DsLocalCommand extends FeatureGateCommand {
  final DataSourceService _dsService;
  final FileService _fileService;

  DsLocalCommand({
    required DataSourceService dataSourceService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _dsService = dataSourceService,
       _fileService = fileService;

  @override
  String get name => 'ds-local';

  @override
  String get description =>
      'Generates a local data source interface and implementation for a feature.';

  @override
  String get invocation => 'fsda $name <cache_key> -f <feature> -m <module>';

  @override
  Future<int> handleFeatureGate(FeatureGateParam param) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Cache key argument is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid cache key: "$rest".');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final cacheKey = rest.first;

    if (!Rules.cacheKeyRegExp.hasMatch(cacheKey)) {
      logger.error('Invalid cache key format: "$cacheKey".');
      logger.log(Rules.cacheKeyDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final dsParam = LocalDsParam(
      featureName: param.featureName,
      featurePath: param.featurePath,
      moduleName: param.moduleName,
      modulePath: param.modulePath,
      cacheKey: cacheKey,
    );

    if (await _fileService.exists(dsParam.interfacePath)) {
      logger.error(
        'Local data source interface already exists at ${dsParam.interfacePath}',
      );
      return errorUsage;
    }

    if (await _fileService.exists(dsParam.implPath)) {
      logger.error(
        'Local data source implementation already exists at ${dsParam.implPath}',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating local data source for feature "${param.featureName}" (${param.moduleName})...',
    );

    try {
      await _dsService.generateLocalDataSource(
        localDs: dsParam,
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Local Data Source Generation Summary',
      );

      progress.complete(
        'Local data source successfully generated for feature "${param.featureName}" (${param.moduleName})!',
      );

      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate local data source: $e');
      return errorSystem;
    }
  }
}
