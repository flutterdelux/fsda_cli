import 'module_gate_param.dart';

class FeatureGateParam extends ModuleGateParam {
  final String featureName;
  final String featurePath;

  const FeatureGateParam({
    required this.featureName,
    required this.featurePath,
    required super.moduleName,
    required super.modulePath,
  });
}
