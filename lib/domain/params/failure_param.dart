import 'module_param.dart';

class FailureParam extends ModuleParam {
  // snake case
  final String name;

  // sentence case
  final String message;

  const FailureParam({
    required this.name,
    required this.message,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory FailureParam.fromModule({
    required ModuleParam module,
    required String name,
    required String message,
  }) {
    return FailureParam(
      name: name,
      message: message,
      moduleName: module.moduleName,
      workspaceName: module.workspaceName,
      workspacePath: module.workspacePath,
    );
  }
}
