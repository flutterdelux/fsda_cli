import 'app_param.dart';

class GenAppParam extends AppParam {
  /// e.g. com.fdelux
  final String org;

  /// e.g. Portal App
  final String appTitle;

  /// e.g. Flutter Delux
  final String orgName;

  const GenAppParam({
    required this.org,
    required this.appTitle,
    required this.orgName,
    required super.workspaceName,
    required super.workspacePath,
    required super.appName,
  });

  factory GenAppParam.fromApp({
    required AppParam app,
    required String appTitle,
    required String org,
    required String orgName,
  }) {
    return GenAppParam(
      org: org,
      appTitle: appTitle,
      orgName: orgName,
      workspaceName: app.workspaceName,
      workspacePath: app.workspacePath,
      appName: app.appName,
    );
  }
}
