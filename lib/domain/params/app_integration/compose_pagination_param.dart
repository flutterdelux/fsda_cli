import 'compose_retrieval_param.dart';

class ComposePaginationParam extends ComposeRetrievalParam {
  const ComposePaginationParam({
    required super.appName,
    required super.appPath,
    required super.moduleName,
    required super.modulePath,
    required super.featureName,
    required super.featurePath,
    required super.logicFlowSlice,
    required super.target,
    required super.uiSlice,
  });

  factory ComposePaginationParam.fromRetrieval({
    required ComposeRetrievalParam retrieval,
  }) {
    return ComposePaginationParam(
      appName: retrieval.appName,
      appPath: retrieval.appPath,
      moduleName: retrieval.moduleName,
      modulePath: retrieval.modulePath,
      featureName: retrieval.featureName,
      featurePath: retrieval.featurePath,
      logicFlowSlice: retrieval.logicFlowSlice,
      target: retrieval.target,
      uiSlice: retrieval.uiSlice,
    );
  }
}
