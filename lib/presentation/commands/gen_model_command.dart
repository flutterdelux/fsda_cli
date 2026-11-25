import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/model_param_x.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/model_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/model_service.dart';
import '../resolvers/model_resolver.dart';
import 'wrapper/feature_gate_command.dart';

class GenModelCommand extends FeatureGateCommand {
  final ModelService _modelService;
  final FileService _fileService;

  GenModelCommand({
    required ModelService modelService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _modelService = modelService,
       _fileService = fileService {
    argParser.addOption(
      ModelResolverKeys.name,
      abbr: 'n',
      help: 'Define model name (e.g., --name "task_entity").',
    );
    argParser.addMultiOption(
      ModelResolverKeys.prop,
      abbr: 'p',
      help:
          'Define model property (e.g., --prop "String:id" --prop "TaskStatus:status::TaskStatusConverter").',
    );
    argParser.addFlag(
      ModelResolverKeys.isL10n,
      negatable: false,
      help: 'Inject localization keys into module ARB files.',
      defaultsTo: false,
    );
    argParser.addFlag(
      ModelResolverKeys.isWithDto,
      negatable: false,
      help: 'Automatically generate a paired DTO model.',
      defaultsTo: false,
    );
    argParser.addFlag(
      ModelResolverKeys.isWithRequest,
      negatable: false,
      help: 'Automatically generate a paired Request model.',
      defaultsTo: false,
    );
  }

  @override
  String get name => 'gen-model';

  @override
  String get description =>
      'Generates a model (entity, dto, request, param, response) with Freezed and optional JsonSerializable.';

  @override
  String get invocation =>
      'fsda $name -n <name_type> -p "<type>:<name>[:default[:converter]]" -f <feature> -m <module> [--l10n]';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    List<ModelParam> models;
    try {
      models = ModelResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      if (e is FormatException) {
        logger.error(e.message);
      } else {
        logger.error(e.toString());
      }
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    for (final model in models) {
      if (await _fileService.exists(model.modelPath)) {
        logger.error('Model file already exists at ${model.modelPath}');
        return errorUsage;
      }
    }

    final progress = logger.progress(
      'Generating models in feature "${feature.featureName}"...',
    );

    for (final model in models) {
      try {
        progress.update('Generating $model...');
        await _modelService.generate(
          model: model,
          onProgress: (msg) => progress.update(msg),
        );

        progress.complete('Model ${model.moduleName} successfully generated!');
      } catch (e) {
        progress.fail('Failed to generate models: $e');
        return errorSystem;
      }
    }

    final reportBuffer = reportService.generateReport(
      operationLabel: 'Model Generation Summary',
    );
    logger.log(reportBuffer.toString());
    return successCode;
  }
}
