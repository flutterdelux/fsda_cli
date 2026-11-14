import 'app_integration_param.dart';

class RegModuleParam extends AppIntegrationParam {
  const RegModuleParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
  });

  factory RegModuleParam.fromAppIntegration(AppIntegrationParam param) {
    return RegModuleParam(
      appName: param.appName,
      appPath: param.appPath,
      moduleName: param.moduleName,
      modulePath: param.modulePath,
      featureName: param.featureName,
      featurePath: param.featurePath,
    );
  }
}
