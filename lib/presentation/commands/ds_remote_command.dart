import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/ds_param_x.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/remote_ds_param.dart';
import '../../infrastructure/services/data_source_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/remote_ds_resolver.dart';
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
       _fileService = fileService {
    argParser.addOption(
      RemoteDsResolverKeys.basePath,
      help:
          'The base endpoint path for the remote data source (e.g., "/tasks").',
    );
  }

  @override
  String get name => 'ds-remote';

  @override
  String get description =>
      'Generates a remote data source interface and implementation for a feature.';

  @override
  String get invocation =>
      'fsda $name --base-path "</base-path>" -f <feature> -m <module>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    RemoteDsParam remoteDs;
    try {
      remoteDs = RemoteDsResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await _fileService.exists(remoteDs.interfacePath)) {
      logger.error(
        'Remote data source interface already exists at ${remoteDs.interfacePath}',
      );
      return errorUsage;
    }

    if (await _fileService.exists(remoteDs.implPath)) {
      logger.error(
        'Remote data source implementation already exists at ${remoteDs.implPath}',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating remote data source for "${remoteDs.moduleName}/${remoteDs.featureName}"...',
    );

    try {
      await _dsService.generateRemoteDataSource(
        remoteDs: remoteDs,
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Remote Data Source Generation Summary',
      );

      progress.complete(
        'Remote data source successfully generated for "${remoteDs.moduleName}/${remoteDs.featureName}"!',
      );

      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate remote data source: $e');
      return errorSystem;
    }
  }
}
