import 'workspace_param.dart';

class AppParam extends WorkspaceParam {
  /// e.g. portal_app
  final String appName;

  const AppParam({
    required this.appName,

    required super.workspaceName,
    required super.workspacePath,
  });

  factory AppParam.fromWorkspace({
    required WorkspaceParam workspace,
    required String appName,
  }) {
    return AppParam(
      workspaceName: workspace.workspaceName,
      workspacePath: workspace.workspacePath,
      appName: appName,
    );
  }
}
