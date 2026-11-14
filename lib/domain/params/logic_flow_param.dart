import '../enums/logic_flow_type.dart';
import '../enums/state_control.dart';
import '../models/logic_uc_model.dart';
import 'slice_gate_param.dart';

class LogicFlowParam extends SliceGateParam {
  final LogicFlowType type;
  final LogicUcModel uc;
  final StateControl control;

  const LogicFlowParam({
    required this.type,
    required this.uc,
    this.control = .cubit,
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
  });

  factory LogicFlowParam.fromSliceGate({
    required SliceGateParam sliceGate,
    required LogicFlowType type,
    required LogicUcModel uc,
    StateControl control = StateControl.cubit,
  }) {
    return LogicFlowParam(
      type: type,
      uc: uc,
      control: control,
      featureName: sliceGate.featureName,
      featurePath: sliceGate.featurePath,
      moduleName: sliceGate.moduleName,
      modulePath: sliceGate.modulePath,
      slice: sliceGate.slice,
    );
  }
}
