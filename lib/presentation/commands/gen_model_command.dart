import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/enums/model_type.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../domain/params/model_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/model_service.dart';
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
    argParser.addMultiOption(
      'prop',
      abbr: 'p',
      help:
          'Define model property (e.g., --prop "String:id" --prop "TaskStatus:status::TaskStatusConverter").',
    );
    argParser.addFlag(
      'l10n',
      negatable: false,
      help: 'Inject localization keys into module ARB files.',
    );
    argParser.addFlag(
      'with-dto',
      negatable: false,
      help: 'Automatically generate a paired DTO model.',
    );
    argParser.addFlag(
      'with-request',
      negatable: false,
      help: 'Automatically generate a paired Request model.',
    );
  }

  @override
  String get name => 'gen-model';

  @override
  String get description =>
      'Generates a model (entity, dto, request, param, response) with Freezed and optional JsonSerializable.';

  @override
  String get invocation =>
      'fsda gen-model <name_type> -p "<type>:<name>[:default[:converter]]" -f <feature> -m <module> [--l10n]';

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Model name with type suffix is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid arguments: "$rest".');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final modelArg = rest.first;

    if (!Rules.modelRegExp.hasMatch(modelArg)) {
      logger.error('Invalid model name format: "$modelArg".');
      logger.log(Rules.modelDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final parts = modelArg.split('_');
    if (parts.length < 2) {
      logger.error('Invalid model name: "$modelArg".');
      logger.log(
        'Model name must include a base name and a valid type suffix (e.g., task_entity, user_profile_dto).',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final typeStr = parts.last;
    final modelType = ModelType.fromValue(typeStr);

    if (modelType == null) {
      logger.error('Invalid model type suffix: "$typeStr".');
      logger.log(
        'Supported type suffixes: ${ModelType.values.map((e) => e.value).join(', ')}.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final modelName = parts.sublist(0, parts.length - 1).join('_');

    if (!Rules.modelRegExp.hasMatch(modelName)) {
      logger.error('Invalid base model name: "$modelName".');
      logger.log(Rules.modelDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    // Mengambil argumen multi-option 'prop'
    final propArgs = argResults?['prop'] as List<String>?;
    final isInjectL10n = argResults?['l10n'] as bool? ?? false;

    if (propArgs == null || propArgs.isEmpty) {
      logger.error(
        'Missing required options (--prop). At least one property is required.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    // Parsing Props
    final propsList = _parseProps(
      rawProps: propArgs,
      withConverter: switch (modelType) {
        .dto || .request || .response => true,
        _ => false,
      },
    );
    if (propsList == null) return errorUsage;

    if (isInjectL10n && modelType != ModelType.entity) {
      logger.error('Invalid option --l10n: Only set --l10n for entity type.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final isWithDto = argResults?['with-dto'] as bool? ?? false;
    final isWithRequest = argResults?['with-request'] as bool? ?? false;

    if (isWithDto && modelType != ModelType.entity) {
      logger.error(
        'Invalid option --with-dto: Only allowed for entity model type.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (isWithRequest && modelType != ModelType.param) {
      logger.error(
        'Invalid option --with-request: Only allowed for param model type.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final modelPath = p.join(
      featureGateParam.featurePath,
      modelType.resolveParentDirUnderFeature(),
      '${modelName}_${modelType.value}.dart',
    );

    final modelsToGenerate = <ModelParam>[];

    modelsToGenerate.add(
      ModelParam.fromFeatureGate(
        name: modelName,
        path: modelPath,
        type: modelType,
        props: propsList,
        isInjectL10n: isInjectL10n,
        featureGate: featureGateParam,
      ),
    );

    final pairedModelType = isWithDto
        ? ModelType.dto
        : isWithRequest
        ? ModelType.request
        : null;

    if (pairedModelType != null) {
      final pairedPath = p.join(
        featureGateParam.featurePath,
        pairedModelType.resolveParentDirUnderFeature(),
        '${modelName}_${pairedModelType.value}.dart',
      );

      modelsToGenerate.add(
        ModelParam.fromFeatureGate(
          name: modelName,
          path: pairedPath,
          type: pairedModelType,
          props: propsList,
          isInjectL10n: false,
          featureGate: featureGateParam,
        ),
      );
    }

    for (final model in modelsToGenerate) {
      if (await _fileService.exists(model.path)) {
        logger.error('Model file already exists at ${model.path}');
        return errorUsage;
      }
    }

    final progress = logger.progress(
      'Generating models in feature "${featureGateParam.featureName}"...',
    );
    for (final model in modelsToGenerate) {
      try {
        progress.update('Generating ${model.type.value} model...');
        await _modelService.generateModel(
          model: model,
          onProgress: (msg) => progress.update(msg),
        );

        progress.complete('Model ${model.name} successfully generated!');
      } catch (e) {
        if (model.type == pairedModelType) {
          final reportBuffer = reportService.generateReport(
            operationLabel: 'Model Generation Summary',
          );
          logger.log(reportBuffer.toString());
        }
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

  // Parser disesuaikan menerima List<String> langsung dari multi-flag --prop
  List<PropModel>? _parseProps({
    required List<String> rawProps,
    required bool withConverter,
  }) {
    final propsList = <PropModel>[];
    for (final raw in rawProps) {
      final parts = raw.split(':');
      final type = parts.isNotEmpty ? parts[0].trim() : '';
      final propName = parts.length > 1 ? parts[1].trim() : '';
      final defaultValue = parts.length > 2 ? parts[2].trim() : '';
      final converter = parts.length > 3 ? parts[3].trim() : '';

      if (type.isEmpty) {
        logger.error('Invalid property type in "$raw": type is empty.');
        logger.log('Usage: $invocation');
        return null;
      }

      if (propName.isEmpty) {
        logger.error('Invalid property name in "$raw": name is empty.');
        logger.log('Usage: $invocation');
        return null;
      }

      if (!Rules.propNameRegExp.hasMatch(propName)) {
        logger.error('Invalid property name: "$propName".');
        logger.log(Rules.propNameDescription);
        logger.log('Usage: $invocation');
        return null;
      }

      if (withConverter && converter.isNotEmpty) {
        if (!Rules.propConverterRegExp.hasMatch(converter)) {
          logger.error('Invalid converter name: "$converter".');
          logger.log(Rules.propConverterDescription);
          logger.log('Usage: $invocation');
          return null;
        }
      }

      propsList.add(
        PropModel(
          type: type,
          name: propName,
          defaultValue: defaultValue,
          converter: converter,
        ),
      );
    }
    return propsList;
  }
}
