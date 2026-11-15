class AppParam {
  /// e.g. portalapp
  final String projectName;
  final String projectPath;

  /// e.g. com.fdelux
  final String org;

  /// e.g. Portal App
  final String appName;

  /// e.g. Flutter Delux
  final String orgName;

  const AppParam({
    required this.projectName,
    required this.projectPath,
    required this.org,
    required this.appName,
    required this.orgName,
  });
}
