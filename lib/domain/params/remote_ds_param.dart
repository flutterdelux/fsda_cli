import 'ds_param.dart';
import 'feature_param.dart';

class RemoteDsParam extends DsParam {
  /// e.g. "/tasks"
  final String basePath;

  const RemoteDsParam({
    required this.basePath,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  }) : super(mode: .remote);

  factory RemoteDsParam.fromFeature({
    required FeatureParam feature,
    required String basePath,
  }) {
    return RemoteDsParam(
      basePath: basePath,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
