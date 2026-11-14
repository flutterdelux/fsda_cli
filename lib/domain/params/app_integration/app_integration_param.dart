class AppIntegrationParam {
  final String appName;
  final String appPath;
  final String moduleName;
  final String modulePath;
  final String? featureName;
  final String? featurePath;

  const AppIntegrationParam({
    required this.appName,
    required this.appPath,
    required this.moduleName,
    required this.modulePath,
    required this.featureName,
    required this.featurePath,
  });
}
