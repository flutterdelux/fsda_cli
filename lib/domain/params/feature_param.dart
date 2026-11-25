import 'module_param.dart';

class FeatureParam extends ModuleParam {
  final String featureName;

  const FeatureParam({
    required this.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory FeatureParam.fromModule({
    required ModuleParam module,
    required String featureName,
  }) {
    return FeatureParam(
      featureName: featureName,
      moduleName: module.moduleName,
      workspaceName: module.workspaceName,
      workspacePath: module.workspacePath,
    );
  }
}
