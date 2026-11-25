import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/feature_param_x.dart';
import '../../core/extensions/sequence_param_x.dart';
import '../../domain/enums/ds_mode.dart';
import '../../domain/enums/flow_type.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/sequence_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/helpers/method_service.dart';
import '../../infrastructure/services/sequence_service.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import '../resolvers/sequence_resolver.dart';
import 'wrapper/feature_gate_command.dart';

class GenSequenceCommand extends FeatureGateCommand {
  final SequenceService _sequenceService;
  final FileService _fileService;
  final MethodService _methodService;

  GenSequenceCommand({
    required SequenceService sequenceService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required FileService fileService,
    required MethodService methodService,
  }) : _sequenceService = sequenceService,
       _fileService = fileService,
       _methodService = methodService {
    argParser.addOption(
      SequenceResolverKeys.action,
      help: 'Data action: post, get, put, patch, or delete.',
    );
    argParser.addOption(
      SequenceResolverKeys.uc,
      help: 'Use case name in snake_case (e.g., --uc task_create_use_case).',
    );
    argParser.addOption(
      SequenceResolverKeys.method,
      abbr: 'd',
      help: 'Repository/Datasource method name (e.g., -d create_task).',
    );
    argParser.addOption(
      SequenceResolverKeys.flow,
      help: 'Flow type: async, sync, or stream.',
      defaultsTo: FlowType.asynchronous.value,
    );
    argParser.addOption(
      SequenceResolverKeys.ds,
      help: 'Datasource mode: remote or local.',
      defaultsTo: DsMode.remote.value,
    );
    argParser.addFlag(
      SequenceResolverKeys.isList,
      negatable: false,
      help: 'Indicates if return type is a List of entities/dtos.',
      defaultsTo: false,
    );
    argParser.addMultiOption(
      SequenceResolverKeys.model,
      help:
          'Model names attached to this sequence (e.g., --model task_entity --model task_dto).',
    );
  }

  @override
  bool get featureShouldExists => true;

  @override
  String get name => 'gen-sequence';

  @override
  String get description =>
      'Generates a complete data-to-domain sequence (UseCase -> Repository -> DataSource).';

  @override
  String get invocation =>
      'fsda $name -m <module> -f <feature> --action <action> --uc <usecase> -d <method> [--flow <flow_type>] [--ds <mode>] [--list] [--model <model_1>]';

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final SequenceParam param;
    try {
      param = SequenceResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (param.hasResponse && !await _fileService.exists(param.responsePath)) {
      logger.error(
        'Model ${param.response} not found at ${param.responsePath}',
      );
      return errorUsage;
    }

    if (param.hasDto && !await _fileService.exists(param.dtoPath)) {
      logger.error('Model ${param.dto} not found at ${param.dtoPath}');
      return errorUsage;
    }

    if (param.hasRequest && !await _fileService.exists(param.requestPath)) {
      logger.error('Model ${param.request} not found at ${param.requestPath}');
      return errorUsage;
    }

    if (param.hasEntity && !await _fileService.exists(param.entityPath)) {
      logger.error('Model ${param.entity} not found at ${param.entityPath}');
      return errorUsage;
    }

    if (param.hasParam && !await _fileService.exists(param.paramPath)) {
      logger.error('Model ${param.param} not found at ${param.paramPath}');
      return errorUsage;
    }

    if (await _fileService.exists(param.ucPath)) {
      logger.error('Use case already exists at ${param.ucPath}');
      return errorUsage;
    }

    if (!await _fileService.exists(param.dsInterfacePath)) {
      logger.error(
        '${param.dsMode.value.titleCase} data source interface not found.',
      );
      return errorUsage;
    }

    if (!await _fileService.exists(param.dsImplPath)) {
      logger.error(
        '${param.dsMode.value.titleCase} data source implementation not found.',
      );
      return errorUsage;
    }

    if (await _methodService.hasMethod(
      path: param.dsInterfacePath,
      methodName: param.method,
    )) {
      logger.error(
        'Method "${param.method.camelCase}" already exists in Data Source (${param.dsInterfacePath}).',
      );
      return errorUsage;
    }

    if (await _methodService.hasMethod(
      path: param.repoInterfacePath,
      methodName: param.method,
    )) {
      logger.error(
        'Method "${param.method.camelCase}" already exists in Repository (${param.repoInterfacePath}).',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating sequence "${param.usecase}" for feature "${feature.featureName}"...',
    );

    try {
      await _sequenceService.generate(
        sequence: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Sequence "${param.usecase}" successfully generated and wired!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Sequence Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate sequence: $e');
      return errorSystem;
    }
  }
}
