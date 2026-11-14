import '../enums/action.dart';
import '../enums/ds_mode.dart';
import '../enums/flow_type.dart';
import 'feature_gate_param.dart';

class SequenceParam extends FeatureGateParam {
  final Action action;
  final String usecase;
  final String usecasePath;
  final String method;

  final FlowType flow;
  final DsMode dsMode;

  // Modelling
  final bool isList;
  final String? response;
  final String? responsePath;
  final String? dto;
  final String? dtoPath;
  final String? entity;
  final String? entityPath;
  final String? request;
  final String? requestPath;
  final String? param;
  final String? paramPath;

  const SequenceParam({
    required this.action,
    required this.usecase,
    required this.usecasePath,
    required this.method,
    this.flow = .asynchronous,
    this.dsMode = .remote,
    this.isList = false,
    this.entity,
    this.entityPath,
    this.param,
    this.paramPath,
    this.dto,
    this.dtoPath,
    this.request,
    this.requestPath,
    this.response,
    this.responsePath,
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
  });

  factory SequenceParam.fromFeatureGate({
    required FeatureGateParam featureGate,
    required Action action,
    required String usecase,
    required String usecasePath,
    required String method,
    FlowType flow = FlowType.asynchronous,
    DsMode dsMode = DsMode.remote,
    bool isList = false,
    String? entity,
    String? entityPath,
    String? param,
    String? paramPath,
    String? dto,
    String? dtoPath,
    String? request,
    String? requestPath,
    String? response,
    String? responsePath,
  }) {
    return SequenceParam(
      action: action,
      usecase: usecase,
      usecasePath: usecasePath,
      method: method,
      flow: flow,
      dsMode: dsMode,
      isList: isList,
      entity: entity,
      entityPath: entityPath,
      param: param,
      paramPath: paramPath,
      dto: dto,
      dtoPath: dtoPath,
      request: request,
      requestPath: requestPath,
      response: response,
      responsePath: responsePath,
      featureName: featureGate.featureName,
      featurePath: featureGate.featurePath,
      moduleName: featureGate.moduleName,
      modulePath: featureGate.modulePath,
    );
  }
}
