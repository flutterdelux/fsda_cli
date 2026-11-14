import 'feature_gate_param.dart';

class SliceGateParam extends FeatureGateParam {
  final String slice;

  const SliceGateParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required this.slice,
  });

  factory SliceGateParam.fromFeatureGate({
    required FeatureGateParam featureGate,
    required String slice,
  }) {
    return SliceGateParam(
      featureName: featureGate.featureName,
      featurePath: featureGate.featurePath,
      moduleName: featureGate.moduleName,
      modulePath: featureGate.modulePath,
      slice: slice,
    );
  }
}
