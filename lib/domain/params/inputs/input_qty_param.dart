import 'input_gate_param.dart';

class InputQtyParam extends InputGateParam {
  const InputQtyParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
  });

  factory InputQtyParam.fromInputGate({required InputGateParam inputGate}) {
    return InputQtyParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
    );
  }
}
