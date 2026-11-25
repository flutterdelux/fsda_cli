import '../enums/state_control.dart';
import '../models/prop_model.dart';
import 'slice_param.dart';

class LogicParam extends SliceParam {
  final List<PropModel> props;
  final StateControl control;

  const LogicParam({
    required this.props,
    this.control = .cubit,
    required super.featureName,
    required super.moduleName,
    required super.sliceName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory LogicParam.fromSliceGate({
    required SliceParam slice,
    required List<PropModel> props,
    required StateControl control,
  }) {
    return LogicParam(
      props: props,
      control: control,
      featureName: slice.featureName,
      moduleName: slice.moduleName,
      sliceName: slice.sliceName,
      workspaceName: slice.workspaceName,
      workspacePath: slice.workspacePath,
    );
  }
}
