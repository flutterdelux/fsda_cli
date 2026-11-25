import '../../domain/params/app_integration/reg_feature_param.dart';
import '../../domain/params/app_integration/reg_module_param.dart';
import 'app_resolver.dart';
import 'feature_resolver.dart';
import 'module_resolver.dart';

abstract final class RegFeatureResolverKeys {
  /// {@macro AppResolverKeys}
  static const app = AppResolverKeys.app;

  /// {@macro ModuleResolverKeys}
  static const module = ModuleResolverKeys.module;

  /// {@macro FeatureResolverKeys}
  static const feature = FeatureResolverKeys.feature;

  /// {@template FeatureResolverKeys}
  /// `force`
  /// {@endtemplate}
  static const force = 'force';
}

abstract final class RegFeatureResolver {
  static RegFeatureParam resolve({
    required Map<String, dynamic> data,
    required RegModuleParam regModule,
  }) {
    final feature = FeatureResolver.resolve(data: data, module: regModule);

    // ============ force ============
    final rawForcce = data[RegFeatureResolverKeys.force] ?? false;
    if (rawForcce is! bool) {
      throw const FormatException('Force flag must be bool type.');
    }

    return RegFeatureParam(
      appName: regModule.appName,
      moduleName: regModule.moduleName,
      featureName: feature.featureName,
      workspaceName: regModule.workspaceName,
      workspacePath: regModule.workspacePath,
      force: rawForcce,
    );
  }
}
