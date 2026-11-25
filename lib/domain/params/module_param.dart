import 'workspace_param.dart';

class ModuleParam extends WorkspaceParam {
  final String moduleName;

  const ModuleParam({
    required this.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory ModuleParam.fromWorkspace({
    required WorkspaceParam workspace,
    required String moduleName,
  }) {
    return ModuleParam(
      moduleName: moduleName,
      workspaceName: workspace.workspaceName,
      workspacePath: workspace.workspacePath,
    );
  }
}
