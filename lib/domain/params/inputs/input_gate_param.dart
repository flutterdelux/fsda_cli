import '../feature_gate_param.dart';

class InputGateParam extends FeatureGateParam {
  final String field;

  const InputGateParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required this.field,
  });

  factory InputGateParam.fromFeatureGate({
    required FeatureGateParam featureGate,
    required String field,
  }) {
    return InputGateParam(
      featureName: featureGate.featureName,
      featurePath: featureGate.featurePath,
      moduleName: featureGate.moduleName,
      modulePath: featureGate.modulePath,
      field: field,
    );
  }
}
