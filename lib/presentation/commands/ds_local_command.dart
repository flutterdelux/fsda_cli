import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/ds_param_x.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/local_ds_param.dart';
import '../../infrastructure/services/data_source_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/local_ds_resolver.dart';
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
       _fileService = fileService {
    argParser.addOption(
      LocalDsResolverKeys.cacheKey,
      help: 'The local storage cache key (e.g., "cached_tasks").',
    );
  }

  @override
  String get name => 'ds-local';

  @override
  String get description =>
      'Generates a local data source interface and implementation for a feature.';

  @override
  String get invocation =>
      'fsda $name --cache-key <cache_key> -f <feature> -m <module>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    LocalDsParam localDs;
    try {
      localDs = LocalDsResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await _fileService.exists(localDs.interfacePath)) {
      logger.error(
        'Local data source interface already exists at ${localDs.interfacePath}',
      );
      return errorUsage;
    }

    if (await _fileService.exists(localDs.implPath)) {
      logger.error(
        'Local data source implementation already exists at ${localDs.implPath}',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating local data source for "${localDs.moduleName}/${localDs.featureName}"...',
    );

    try {
      await _dsService.generateLocalDataSource(
        localDs: localDs,
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Local Data Source Generation Summary',
      );

      progress.complete(
        'Local data source successfully generated for "${localDs.moduleName}/${localDs.featureName}"!',
      );

      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate local data source: $e');
      return errorSystem;
    }
  }
}
