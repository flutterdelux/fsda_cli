import 'input_gate_param.dart';

class InputImageParam extends InputGateParam {
  final String type;

  const InputImageParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
    this.type = 'NetworkFile',
  });

  factory InputImageParam.fromInputGate({
    required InputGateParam inputGate,
    String valueType = 'NetworkFile',
  }) {
    return InputImageParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
      type: valueType,
    );
  }
}
