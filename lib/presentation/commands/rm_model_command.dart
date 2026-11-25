import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/model_param_x.dart';
import '../../domain/enums/model_type.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/model_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/model_service.dart';
import '../resolvers/model_resolver.dart';
import 'wrapper/feature_gate_command.dart';

class RmModelCommand extends FeatureGateCommand {
  final ModelService _modelService;
  final FileService _fileService;

  RmModelCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required ModelService modelService,
    required FileService fileService,
    required super.directoryService,
  }) : _modelService = modelService,
       _fileService = fileService {
    argParser.addOption(
      ModelResolverKeys.name,
      abbr: 'n',
      help: 'Model name with type suffix (e.g., task_entity, user_dto).',
    );
  }

  @override
  String get name => 'rm-model';

  @override
  String get description =>
      'Removes an existing model, uninjects barrel exports, and cleans up module ARB entries.';

  @override
  String get invocation => 'fsda $name -n <name_type> -f <feature> -m <module>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final String modelName;
    final ModelType modelType;
    try {
      (:modelName, :modelType, parts: _) = ModelResolver.resolveName(
        argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final initParam = ModelParam.fromFeature(
      feature: feature,
      type: modelType,
      modelName: modelName,
      props: const [],
      isL10n: true,
    );

    if (!await _fileService.exists(initParam.modelPath)) {
      logger.error(
        'Model "${initParam.modelName}" not found at ${initParam.modelPath}',
      );
      return errorUsage;
    }

    final props = await _modelService.getPropsFromModelFile(
      initParam.modelPath,
    );

    final param = ModelParam.fromFeature(
      props: props,
      feature: feature,
      type: modelType,
      modelName: initParam.modelName,
      isL10n: initParam.isL10n,
    );

    final progress = logger.progress(
      'Removing model "${param.modelName}" from feature "${param.moduleName}/${param.featureName}"...',
    );

    try {
      await _modelService.remove(
        model: param,
        onProgress: (msg) => progress.update(msg),
      );
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Model Removal Summary',
      );

      progress.complete('Model "${param.modelName}" successfully removed!');
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove model "${param.modelName}": $e');
      return errorSystem;
    }
  }
}
