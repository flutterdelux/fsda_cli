import 'input_gate_param.dart';

class InputTextParam extends InputGateParam {
  const InputTextParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
  });

  factory InputTextParam.fromInputGate({required InputGateParam inputGate}) {
    return InputTextParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
    );
  }
}
