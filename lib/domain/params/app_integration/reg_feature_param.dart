import 'app_integration_param.dart';

class RegFeatureParam extends AppIntegrationParam {
  const RegFeatureParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
  });

  factory RegFeatureParam.fromAppIntegration(AppIntegrationParam param) {
    return RegFeatureParam(
      appName: param.appName,
      appPath: param.appPath,
      moduleName: param.moduleName,
      modulePath: param.modulePath,
      featureName: param.featureName,
      featurePath: param.featurePath,
    );
  }
}
