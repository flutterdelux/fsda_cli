import '../../../core/extensions/arg_results_x.dart';
import '../../../core/extensions/feature_param_x.dart';
import '../../../domain/params/app_integration/reg_feature_param.dart';
import '../../../domain/params/app_integration/reg_module_param.dart';
import '../../resolvers/reg_feature_resolver.dart';
import 'reg_module_gate_command.dart';

abstract class RegFeatureGateCommand extends RegModuleGateCommand {
  RegFeatureGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      RegFeatureResolverKeys.feature,
      abbr: 'f',
      help: 'The target feature name under features/.',
    );
    argParser.addFlag(
      RegFeatureResolverKeys.force,
      help: 'Overwrites existing _<feature>Di() method in module DI.',
      negatable: false,
    );
  }

  @override
  Future<int> handleRegModule(RegModuleParam regModule) async {
    final RegFeatureParam param;
    try {
      param = RegFeatureResolver.resolve(
        regModule: regModule,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!await directoryService.exists(param.featurePath)) {
      logger.error(
        'Feature "${param.featureName}" not found at ${param.featurePath}',
      );
      return errorUsage;
    }

    return handleRegFeature(param);
  }

  Future<int> handleRegFeature(RegFeatureParam regFeature);
}
