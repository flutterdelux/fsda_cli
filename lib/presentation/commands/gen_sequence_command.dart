import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../core/extensions/sequence_param_x.dart';
import '../../domain/enums/action.dart';
import '../../domain/enums/ds_mode.dart';
import '../../domain/enums/flow_type.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../domain/params/sequence_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/helpers/method_service.dart';
import '../../infrastructure/services/sequence_service.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
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
      'uc',
      help: 'Use case name in snake_case (e.g., --uc task_create).',
    );
    argParser.addOption(
      'method',
      abbr: 'd',
      help: 'Repository/Datasource method name (e.g., -d create_task).',
    );
    argParser.addOption(
      'flow',
      help: 'Flow type: async, sync, or stream.',
      defaultsTo: FlowType.asynchronous.value,
    );
    argParser.addOption(
      'ds',
      help: 'Datasource mode: remote or local.',
      defaultsTo: DsMode.remote.value,
    );
    argParser.addFlag(
      'list',
      negatable: false,
      help: 'Indicates if return type is a List of entities/dtos.',
    );
    argParser.addOption(
      'models',
      help: 'Comma-separated models: response,dto,entity,request,param.',
    );
  }

  @override
  String get name => 'gen-sequence';

  @override
  String get description =>
      'Generates a complete data-to-domain sequence (UseCase -> Repository -> DataSource).';

  @override
  String get invocation =>
      'fsda gen-sequence <action> -f <feature> -m <module> --uc <usecase> -d <method> [--models ...]';

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error(
        'Action argument is required (e.g., post, get, put, patch, delete).',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final actionStr = rest.first.toLowerCase();
    final action = Action.fromValue(actionStr);
    if (action == null) {
      logger.error(
        'Invalid action: "$actionStr". Allowed: ${Action.values.join(', ')}.',
      );
      return errorUsage;
    }

    final usecase = argResults?['uc'] as String?;
    final method = argResults?['method'] as String?;

    if (usecase == null ||
        usecase.isEmpty ||
        method == null ||
        method.isEmpty) {
      logger.error(
        'Missing required options: --uc and --method (-d) are mandatory.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    // Validasi aturan regex usecase & method
    if (!Rules.usecaseRegExp.hasMatch(usecase)) {
      logger.error('Invalid use case name: "$usecase".');
      logger.log(Rules.usecaseDescription);
      return errorUsage;
    }

    if (!usecase.endsWith('_use_case')) {
      logger.error(
        'Invalid use case name: "$usecase". Must end with "_use_case" (e.g., --uc task_create_use_case).',
      );
      return errorUsage;
    }

    final usecasePath = p.join(
      featureGateParam.featurePath,
      'domain',
      'usecases',
      '$usecase.dart',
    );
    if (await _fileService.exists(usecasePath)) {
      logger.error('Use case already exists at $usecasePath');
      return errorUsage;
    }

    if (!Rules.methodRegExp.hasMatch(method)) {
      logger.error('Invalid method name: "$method".');
      logger.log(Rules.methodDescription);
      return errorUsage;
    }

    final flowStr = argResults?['flow'] as String;
    final flow = FlowType.fromValue(flowStr);
    if (flow == null) {
      logger.error(
        'Invalid flow: "$flowStr". Allowed: ${FlowType.values.join(', ')}.',
      );
      return errorUsage;
    }

    final dsStr = argResults?['ds'] as String;
    final dsMode = DsMode.fromValue(dsStr);
    if (dsMode == null) {
      logger.error(
        'Invalid flow: "$dsStr". Allowed: ${[DsMode.local.value, DsMode.remote.value].join(', ')}.',
      );
      return errorUsage;
    }

    final dsInterfacePath = p.join(
      featureGateParam.featurePath,
      'data',
      'datasources',
      '${featureGateParam.featureName}_${dsMode.value}_data_source.dart',
    );
    if (!await _fileService.exists(dsInterfacePath)) {
      logger.error(
        '${dsMode.value.titleCase} data source interface not found.',
      );
      return errorUsage;
    }

    final dsImplPath = p.join(
      featureGateParam.featurePath,
      'data',
      'datasources',
      '${featureGateParam.featureName}_${dsMode.value}_data_source_impl.dart',
    );
    if (!await _fileService.exists(dsImplPath)) {
      logger.error(
        '${dsMode.value.titleCase} data source implementation not found.',
      );
      return errorUsage;
    }

    final isList = argResults?['list'] as bool? ?? false;
    final modelsArg = argResults?['models'] as String?;

    final modelMap = <String, Map<String, String?>>{
      '_response': {'name': null, 'sub_dir': 'data/responses', 'path': null},
      '_dto': {'name': null, 'sub_dir': 'data/dtos', 'path': null},
      '_request': {'name': null, 'sub_dir': 'data/requests', 'path': null},
      '_entity': {'name': null, 'sub_dir': 'domain/entities', 'path': null},
      '_param': {'name': null, 'sub_dir': 'domain/params', 'path': null},
    };

    if (modelsArg != null && modelsArg.isNotEmpty) {
      final rawModels = modelsArg
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);

      for (final m in rawModels) {
        final mKey = modelMap.keys.firstWhereOrNull((key) => m.endsWith(key));
        if (mKey == null) {
          logger.error(
            'Invalid model name format: "$m". Must end with ${modelMap.keys.join(', ')}.',
          );
          return errorUsage;
        }
        if (modelMap[mKey]!['name'] != null) {
          logger.error(
            'Duplicate model type found: "$mKey" is specified more than once.',
          );
          return errorUsage;
        }
        final modelPath = p.join(
          featureGateParam.featurePath,
          modelMap[mKey]!['sub_dir'],
          '$m.dart',
        );
        if (!await _fileService.exists(modelPath)) {
          logger.error('Model $m not found at $modelPath');
          return errorUsage;
        }
        modelMap[mKey]!['name'] = m;
        modelMap[mKey]!['path'] = modelPath;
      }
    }

    final sequenceParam = SequenceParam(
      action: action,
      usecase: usecase,
      usecasePath: usecasePath,
      method: method,
      featureName: featureGateParam.featureName,
      featurePath: featureGateParam.featurePath,
      moduleName: featureGateParam.moduleName,
      modulePath: featureGateParam.modulePath,
      flow: flow,
      dsMode: dsMode,
      isList: isList,
      response: modelMap['_response']!['name'],
      responsePath: modelMap['_response']!['path'],
      dto: modelMap['_dto']!['name'],
      dtoPath: modelMap['_dto']!['path'],
      entity: modelMap['_entity']!['name'],
      entityPath: modelMap['_entity']!['path'],
      request: modelMap['_request']!['name'],
      requestPath: modelMap['_request']!['path'],
      param: modelMap['_param']!['name'],
      paramPath: modelMap['_param']!['path'],
    );

    if (await _methodService.hasMethod(
      path: sequenceParam.dsInterfacePath,
      methodName: method,
    )) {
      logger.error(
        'Method "${method.camelCase}" already exists in Data Source (${sequenceParam.dsInterfacePath}).',
      );
      return errorUsage;
    }

    if (await _methodService.hasMethod(
      path: sequenceParam.repoInterfacePath,
      methodName: method,
    )) {
      logger.error(
        'Method "${method.camelCase}" already exists in Repository (${sequenceParam.repoInterfacePath}).',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating sequence "$usecase" for feature "${featureGateParam.featureName}"...',
    );

    try {
      await _sequenceService.generate(
        sequence: sequenceParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Sequence "$usecase" successfully generated and wired!',
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
