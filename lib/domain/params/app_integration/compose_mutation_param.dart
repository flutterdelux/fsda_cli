import 'compose_param.dart';

class ComposeMutationParam extends ComposeParam {
  const ComposeMutationParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
    required super.logicFlowSlice,
    required super.target,
  });

  factory ComposeMutationParam.fromCompose({required ComposeParam compose}) {
    return ComposeMutationParam(
      appName: compose.appName,
      appPath: compose.appPath,
      moduleName: compose.moduleName,
      modulePath: compose.modulePath,
      featureName: compose.featureName,
      featurePath: compose.featurePath,
      logicFlowSlice: compose.logicFlowSlice,
      target: compose.target,
    );
  }
}
