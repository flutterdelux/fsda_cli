import '../app_param.dart';
import '../module_param.dart';

class RegModuleParam extends ModuleParam implements AppParam {
  const RegModuleParam({
    required this.appName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  @override
  final String appName;
}
