import 'module_gate_param.dart';

class FeatureParam extends ModuleGateParam {
  final String name;
  final String path;

  const FeatureParam({
    required this.name,
    required this.path,
    required super.moduleName,
    required super.modulePath,
  });

  factory FeatureParam.fromModuleGate({
    required ModuleGateParam moduleGate,
    required String name,
    required String path,
  }) {
    return FeatureParam(
      name: name,
      path: path,
      moduleName: moduleGate.moduleName,
      modulePath: moduleGate.modulePath,
    );
  }
}
