import '../enums/action.dart';
import '../enums/ds_mode.dart';
import '../enums/flow_type.dart';
import 'feature_param.dart';

class SequenceParam extends FeatureParam {
  final Action action;
  final String usecase;
  final String method;

  final FlowType flow;
  final DsMode dsMode;

  final bool isList;
  final String? response;
  final String? dto;
  final String? entity;
  final String? request;
  final String? param;

  const SequenceParam({
    required this.action,
    required this.usecase,
    required this.method,
    this.flow = .asynchronous,
    this.dsMode = .remote,
    this.isList = false,
    this.entity,
    this.param,
    this.dto,
    this.request,
    this.response,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory SequenceParam.fromFeature({
    required FeatureParam feature,
    required Action action,
    required String usecase,
    required String method,
    FlowType flow = FlowType.asynchronous,
    DsMode dsMode = DsMode.remote,
    bool isList = false,
    String? entity,
    String? param,
    String? dto,
    String? request,
    String? response,
  }) {
    return SequenceParam(
      action: action,
      usecase: usecase,
      method: method,
      flow: flow,
      dsMode: dsMode,
      isList: isList,
      entity: entity,
      param: param,
      dto: dto,
      request: request,
      response: response,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
