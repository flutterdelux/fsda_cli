import 'package:path/path.dart' as p;

import '../../../core/constants/rules.dart';
import '../../../domain/params/feature_gate_param.dart';
import '../../../domain/params/module_gate_param.dart';
import 'module_gate_command.dart';

abstract class FeatureGateCommand extends ModuleGateCommand {
  FeatureGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'Target feature name under lib/src/features/.',
    );
  }

  @override
  Future<int> handleModuleGate(ModuleGateParam moduleGate) async {
    final featureArg = argResults?['feature'] as String?;

    if (featureArg == null || featureArg.isEmpty) {
      logger.error('Missing required options (--module, --feature).');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!Rules.featureRegExp.hasMatch(featureArg)) {
      logger.error('Invalid feature name: "$featureArg".');
      logger.log(Rules.featureDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final resolvedFeaturePath = p.join(
      moduleGate.modulePath,
      'lib',
      'src',
      'features',
      featureArg,
    );
    if (!await directoryService.exists(resolvedFeaturePath)) {
      logger.error('Feature "$featureArg" not found at $resolvedFeaturePath');
      return errorUsage;
    }

    return handleFeatureGate(
      FeatureGateParam(
        featureName: featureArg,
        featurePath: resolvedFeaturePath,
        moduleName: moduleGate.moduleName,
        modulePath: moduleGate.modulePath,
      ),
    );
  }

  Future<int> handleFeatureGate(FeatureGateParam featureGateParam);
}
