import 'feature_param.dart';

class SliceParam extends FeatureParam {
  final String sliceName;

  const SliceParam({
    required this.sliceName,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory SliceParam.fromFeature({
    required FeatureParam feature,
    required String sliceName,
  }) {
    return SliceParam(
      sliceName: sliceName,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
