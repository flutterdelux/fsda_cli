import '../../../core/extensions/arg_results_x.dart';
import '../../../core/extensions/feature_param_x.dart';
import '../../../domain/params/feature_param.dart';
import '../../../domain/params/module_param.dart';
import '../../resolvers/feature_resolver.dart';
import 'module_gate_command.dart';

abstract class FeatureGateCommand extends ModuleGateCommand {
  FeatureGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      FeatureResolverKeys.feature,
      abbr: 'f',
      help: 'Target feature name under lib/src/features/.',
    );
  }

  @override
  bool get moduleShouldExists => true;

  @override
  Future<int> handleModuleGate(ModuleParam module) async {
    FeatureParam feature;
    try {
      feature = FeatureResolver.resolve(
        module: module,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final featureFound = await directoryService.exists(feature.featurePath);

    if (featureShouldExists && !featureFound) {
      logger.error(
        'Feature "${feature.featureName}" not found at ${feature.featurePath}',
      );
      return errorUsage;
    }

    if (!featureShouldExists && featureFound) {
      logger.error(
        'Feature "${feature.featureName}" already exists at ${feature.featurePath}',
      );
      return errorUsage;
    }

    return handleFeatureGate(feature);
  }

  bool get featureShouldExists;

  Future<int> handleFeatureGate(FeatureParam feature);
}
