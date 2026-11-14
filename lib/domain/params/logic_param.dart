import '../enums/state_control.dart';
import '../models/prop_model.dart';
import 'slice_gate_param.dart';

class LogicParam extends SliceGateParam {
  final List<PropModel> props;
  final StateControl control;

  const LogicParam({
    required this.props,
    this.control = .cubit,
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
  });

  factory LogicParam.fromSliceGate({
    required SliceGateParam sliceGate,
    required List<PropModel> props,
    StateControl control = StateControl.cubit,
  }) {
    return LogicParam(
      props: props,
      control: control,
      featureName: sliceGate.featureName,
      featurePath: sliceGate.featurePath,
      moduleName: sliceGate.moduleName,
      modulePath: sliceGate.modulePath,
      slice: sliceGate.slice,
    );
  }
}
