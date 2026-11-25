import '../enums/logic_flow_type.dart';
import '../enums/state_control.dart';
import 'slice_param.dart';

class LogicFlowParam extends SliceParam {
  final LogicFlowType type;
  final String uc;
  final StateControl control;

  const LogicFlowParam({
    required this.type,
    required this.uc,
    this.control = .cubit,
    required super.featureName,
    required super.moduleName,
    required super.sliceName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory LogicFlowParam.fromSlice({
    required SliceParam slice,
    required LogicFlowType type,
    required String uc,
    required StateControl control,
  }) {
    return LogicFlowParam(
      type: type,
      uc: uc,
      control: control,
      featureName: slice.featureName,
      moduleName: slice.moduleName,
      sliceName: slice.sliceName,
      workspaceName: slice.workspaceName,
      workspacePath: slice.workspacePath,
    );
  }
}
