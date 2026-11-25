import '../../core/constants/rules.dart';
import '../../domain/params/app_param.dart';
import '../../domain/params/workspace_param.dart';

abstract final class AppResolverKeys {
  /// {@template AppResolverKeys}
  /// `app`
  /// {@endtemplate}
  static const app = 'app';
}

abstract final class AppResolver {
  static AppParam resolve({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    // ============ app ============
    final rawApp = data[AppResolverKeys.app];
    if (rawApp == null) {
      throw const FormatException('App project name is required.');
    }
    if (rawApp is! String) {
      throw const FormatException('App project name must be String type.');
    }

    final appName = rawApp.trim();
    if (appName.isEmpty) {
      throw const FormatException('App project name cannot be empty.');
    }

    if (!Rules.appNameRegExp.hasMatch(appName)) {
      throw FormatException(
        'Invalid app project name: "$appName".\n'
        '${Rules.appNameDescription}',
      );
    }

    return AppParam.fromWorkspace(workspace: workspace, appName: appName);
  }
}
