import 'feature_gate_param.dart';

class EnumParam extends FeatureGateParam {
  final String name;
  final String path;
  final List<String> values;
  final bool isLower;

  const EnumParam({
    required this.name,
    required this.path,
    required this.isLower,
    required this.values,
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
  });

  factory EnumParam.fromFeatureGate({
    required FeatureGateParam featureGate,
    required String name,
    required String path,
    required List<String> values,
    required bool isLower,
  }) {
    return EnumParam(
      name: name,
      path: path,
      values: values,
      featureName: featureGate.featureName,
      featurePath: featureGate.featurePath,
      moduleName: featureGate.moduleName,
      modulePath: featureGate.modulePath,
      isLower: isLower,
    );
  }
}
