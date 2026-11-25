import '../../enums/compose_type.dart';
import 'reg_feature_param.dart';

class ComposeParam extends RegFeatureParam {
  final ComposeType type;
  final String target;
  final String logicFlowSlice;
  final String? uiSlice;
  final String? logicSlice;
  final bool withRoute;

  const ComposeParam({
    required this.type,
    required this.target,
    required this.logicFlowSlice,
    this.uiSlice,
    this.logicSlice,
    this.withRoute = false,
    required super.appName,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory ComposeParam.fromRegFeature({
    required RegFeatureParam regFeature,
    required ComposeType type,
    required String target,
    required String logicFlowSlice,
    String? uiSlice,
    String? logicSlice,
    required bool withRoute,
  }) {
    return ComposeParam(
      type: type,
      target: target,
      logicFlowSlice: logicFlowSlice,
      uiSlice: uiSlice,
      logicSlice: logicSlice,
      appName: regFeature.appName,
      moduleName: regFeature.moduleName,
      featureName: regFeature.featureName,
      workspaceName: regFeature.workspaceName,
      workspacePath: regFeature.workspacePath,
      withRoute: withRoute,
    );
  }
}
