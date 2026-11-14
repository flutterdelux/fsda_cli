import 'input_gate_param.dart';

class InputSwitchParam extends InputGateParam {
  const InputSwitchParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
  });

  factory InputSwitchParam.fromInputGate({required InputGateParam inputGate}) {
    return InputSwitchParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
    );
  }
}
