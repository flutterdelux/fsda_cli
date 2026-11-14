import 'input_gate_param.dart';

class InputPasswordParam extends InputGateParam {
  const InputPasswordParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
  });

  factory InputPasswordParam.fromInputGate({
    required InputGateParam inputGate,
  }) {
    return InputPasswordParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
    );
  }
}
