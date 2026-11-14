import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/enums/model_type.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../domain/params/model_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/model_service.dart';
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
       _fileService = fileService;

  @override
  String get name => 'rm-model';

  @override
  String get description =>
      'Removes an existing model, uninjects barrel exports, and cleans up module ARB entries.';

  @override
  String get invocation => 'fsda rm-model <name_type> -f <feature> -m <module>';

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

    // Gabungkan kembali bagian sebelumnya sebagai nama dasar model
    final modelName = parts.sublist(0, parts.length - 1).join('_');

    if (!Rules.modelRegExp.hasMatch(modelName)) {
      logger.error('Invalid base model name: "$modelName".');
      logger.log(Rules.modelDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final fileName = '${modelName}_${modelType.value}.dart';
    final modelPath = p.join(
      featureGateParam.featurePath,
      modelType.resolveParentDirUnderFeature(),
      fileName,
    );

    if (!await _fileService.exists(modelPath)) {
      logger.error('Model "$modelArg" not found at $modelPath');
      return errorUsage;
    }

    final modelParam = ModelParam.fromFeatureGate(
      name: modelName,
      path: modelPath,
      type: modelType,
      props: await _modelService.getPropsFromModelFile(modelPath),
      isInjectL10n:
          true, // Dipakai agar service tahu perlu membersihkan key ARB jika ada
      featureGate: featureGateParam,
    );

    final progress = logger.progress(
      'Removing model "$modelArg" from feature "${modelParam.featureName}" (${modelParam.moduleName})...',
    );

    try {
      await _modelService.removeModel(
        model: modelParam,
        onProgress: (msg) => progress.update(msg),
      );
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Model Removal Summary',
      );

      progress.complete('Model "$modelArg" successfully removed!');
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove model $modelArg: $e');
      return errorSystem;
    }
  }
}
