import 'input_gate_param.dart';

class InputNumberParam extends InputGateParam {
  final String type;
  const InputNumberParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
    required this.type,
  });

  factory InputNumberParam.fromInputGate({
    required InputGateParam inputGate,
    String type = 'int',
  }) {
    return InputNumberParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
      type: type,
    );
  }
}
