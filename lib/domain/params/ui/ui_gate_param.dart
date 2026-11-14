import '../slice_gate_param.dart';

class UiGateParam extends SliceGateParam {
  final String model;

  const UiGateParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
    required this.model,
  });

  factory UiGateParam.fromSliceGate({
    required SliceGateParam sliceGate,
    required String model,
  }) {
    return UiGateParam(
      featureName: sliceGate.featureName,
      featurePath: sliceGate.featurePath,
      moduleName: sliceGate.moduleName,
      modulePath: sliceGate.modulePath,
      slice: sliceGate.slice,
      model: model,
    );
  }
}
