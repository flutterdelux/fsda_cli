import '../../core/constants/rules.dart';
import '../../domain/params/module_param.dart';
import '../../domain/params/workspace_param.dart';

abstract final class ModuleResolverKeys {
  /// {@template ModuleResolverKeys}
  /// `module`
  /// {@endtemplate}
  static const module = 'module';
}

abstract final class ModuleResolver {
  static ModuleParam resolve({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    // ============ module ============
    final rawModule = data[ModuleResolverKeys.module];
    if (rawModule == null) {
      throw const FormatException('Module name is required.');
    }
    if (rawModule is! String) {
      throw const FormatException('Module name must be String type.');
    }

    final moduleName = rawModule.trim();
    if (moduleName.isEmpty) {
      throw const FormatException('Module name cannot be empty.');
    }

    if (!Rules.moduleRegExp.hasMatch(moduleName)) {
      throw FormatException(
        'Invalid module name: "$moduleName".\n'
        '${Rules.moduleDescription}',
      );
    }

    return ModuleParam.fromWorkspace(
      workspace: workspace,
      moduleName: moduleName,
    );
  }
}
