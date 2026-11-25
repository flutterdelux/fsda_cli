import '../feature_param.dart';
import 'reg_module_param.dart';

class RegFeatureParam extends RegModuleParam implements FeatureParam {
  final bool force;

  const RegFeatureParam({
    required this.featureName,
    required super.moduleName,
    required super.appName,
    required super.workspaceName,
    required super.workspacePath,
    this.force = false,
  });

  @override
  final String featureName;
}
