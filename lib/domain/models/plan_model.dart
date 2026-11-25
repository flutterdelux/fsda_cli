import '../params/app_integration/compose_param.dart';
import '../params/app_param.dart';
import '../params/ds_param.dart';
import '../params/enum_param.dart';
import '../params/failure_param.dart';
import '../params/feature_param.dart';
import '../params/input_param.dart';
import '../params/logic_flow_param.dart';
import '../params/logic_param.dart';
import '../params/model_param.dart';
import '../params/module_param.dart';
import '../params/sequence_param.dart';
import '../params/slice_param.dart';
import '../params/ui_param.dart';

sealed class PlanModel {
  const PlanModel();
}

final class AppPlanModel extends PlanModel {
  final AppParam app;
  final List<ComposeParam> composes;

  const AppPlanModel({required this.app, this.composes = const []});
}

final class ModulePlanModel extends PlanModel {
  final ModuleParam module;
  final List<FailureParam> failures;

  const ModulePlanModel({required this.module, this.failures = const []});
}

final class FeaturePlanModel extends PlanModel {
  final FeatureParam feature;
  final List<DsParam> datasources;
  final List<EnumParam> enums;
  final List<ModelParam> models;
  final List<SequenceParam> sequences;
  final List<LogicParam> logics;
  final List<LogicFlowParam> logicFlows;
  final List<InputParam> inputs;
  final List<UiParam> uis;

  const FeaturePlanModel({
    required this.feature,
    this.datasources = const [],
    this.enums = const [],
    this.models = const [],
    this.sequences = const [],
    this.logics = const [],
    this.logicFlows = const [],
    this.inputs = const [],
    this.uis = const [],
  });
}

final class SlicePlanModel extends PlanModel {
  final SliceParam slice;
  final List<DsParam> datasources;
  final List<EnumParam> enums;
  final List<ModelParam> models;
  final List<SequenceParam> sequences;
  final List<LogicParam> logics;
  final List<LogicFlowParam> logicFlows;
  final List<InputParam> inputs;
  final List<UiParam> uis;

  const SlicePlanModel({
    required this.slice,
    this.datasources = const [],
    this.enums = const [],
    this.models = const [],
    this.sequences = const [],
    this.logics = const [],
    this.logicFlows = const [],
    this.inputs = const [],
    this.uis = const [],
  });
}
