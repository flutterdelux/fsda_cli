import 'app_integration_param.dart';

class ComposeParam extends AppIntegrationParam {
  final String target;
  final String logicFlowSlice;

  const ComposeParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
    required this.logicFlowSlice,
    required this.target,
  });

  factory ComposeParam.fromAppIntegration({
    required AppIntegrationParam param,
    required String logicFlowSlice,
    required String target,
  }) {
    return ComposeParam(
      appName: param.appName,
      appPath: param.appPath,
      moduleName: param.moduleName,
      modulePath: param.modulePath,
      featureName: param.featureName,
      featurePath: param.featurePath,
      logicFlowSlice: logicFlowSlice,
      target: target,
    );
  }
}
