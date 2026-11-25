import '../../domain/params/app_integration/reg_module_param.dart';
import '../../domain/params/workspace_param.dart';
import 'app_resolver.dart';
import 'module_resolver.dart';

abstract final class RegModuleResolverKeys {
  /// {@macro AppResolverKeys}
  static const app = AppResolverKeys.app;

  /// {@macro ModuleResolverKeys}
  static const module = ModuleResolverKeys.module;
}

abstract final class RegModuleResolver {
  static RegModuleParam resolve({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    final app = AppResolver.resolve(data: data, workspace: workspace);
    final module = ModuleResolver.resolve(data: data, workspace: workspace);

    return RegModuleParam(
      appName: app.appName,
      moduleName: module.moduleName,
      workspaceName: workspace.workspaceName,
      workspacePath: workspace.workspacePath,
    );
  }
}
