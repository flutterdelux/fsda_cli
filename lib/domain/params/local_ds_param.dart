import 'ds_param.dart';
import 'feature_param.dart';

class LocalDsParam extends DsParam {
  /// e.g. auth_token
  final String cacheKey;

  const LocalDsParam({
    required this.cacheKey,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  }) : super(mode: .local);

  factory LocalDsParam.fromFeature({
    required FeatureParam feature,
    required String cacheKey,
  }) {
    return LocalDsParam(
      cacheKey: cacheKey,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
