import 'compose_param.dart';

class ComposeRetrievalParam extends ComposeParam {
  final String uiSlice;

  const ComposeRetrievalParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
    required super.logicFlowSlice,
    required super.target,
    required this.uiSlice,
  });

  factory ComposeRetrievalParam.fromCompose({
    required ComposeParam compose,
    required String uiSlice,
  }) {
    return ComposeRetrievalParam(
      appName: compose.appName,
      appPath: compose.appPath,
      moduleName: compose.moduleName,
      modulePath: compose.modulePath,
      featureName: compose.featureName,
      featurePath: compose.featurePath,
      logicFlowSlice: compose.logicFlowSlice,
      target: compose.target,
      uiSlice: uiSlice,
    );
  }
}
