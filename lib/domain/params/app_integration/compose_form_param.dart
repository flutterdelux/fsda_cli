import 'compose_param.dart';

class ComposeFormParam extends ComposeParam {
  final String logicSlice;
  final String uiSlice;

  const ComposeFormParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
    required super.logicFlowSlice,
    required super.target,
    required this.logicSlice,
    required this.uiSlice,
  });

  factory ComposeFormParam.fromCompose({
    required ComposeParam compose,
    required String logicSlice,
    required String uiSlice,
  }) {
    return ComposeFormParam(
      appName: compose.appName,
      appPath: compose.appPath,
      moduleName: compose.moduleName,
      modulePath: compose.modulePath,
      featureName: compose.featureName,
      featurePath: compose.featurePath,
      logicFlowSlice: compose.logicFlowSlice,
      target: compose.target,
      logicSlice: logicSlice,
      uiSlice: uiSlice,
    );
  }
}
