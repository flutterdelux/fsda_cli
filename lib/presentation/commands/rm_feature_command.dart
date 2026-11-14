import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/module_gate_param.dart';
import '../../infrastructure/services/feature_service.dart';
import 'wrapper/module_gate_command.dart';

class RmFeatureCommand extends ModuleGateCommand {
  final FeatureService _featureService;

  RmFeatureCommand({
    required FeatureService featureService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _featureService = featureService;

  @override
  String get name => 'rm-feature';

  @override
  String get description =>
      'Removes an existing FSDA Architecture feature structure inside a target module.';

  @override
  String get invocation => 'fsda rm-feature <feature> -m <module>';

  @override
  Future<int> handleModuleGate(ModuleGateParam moduleGate) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Feature name is required.\nUsage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid feature name: "$rest".');
      logger.log(Rules.featureDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final featureName = rest.first;
    if (!Rules.featureRegExp.hasMatch(featureName)) {
      logger.error('Invalid feature name: "$featureName".');
      logger.log(Rules.featureDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final featurePath = p.join(
      moduleGate.modulePath,
      'lib',
      'src',
      'features',
      featureName,
    );
    if (!await directoryService.exists(featurePath)) {
      logger.error('Feature "$featureName" not found at $featurePath');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final feature = FeatureParam.fromModuleGate(
      name: featureName,
      path: featurePath,
      moduleGate: moduleGate,
    );

    final progress = logger.progress(
      'Removing feature "$featureName" from module "${feature.moduleName}"...',
    );

    try {
      await _featureService.removeFeature(
        feature: feature,
        onProgress: (msg) => progress.update(msg),
      );

      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Feature Removal Summary',
      );

      progress.complete(
        'Feature "$featureName" successfully removed from module "${feature.moduleName}"!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove feature $featureName: $e');
      return errorSystem;
    }
  }
}
