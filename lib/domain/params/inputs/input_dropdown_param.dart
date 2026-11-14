import 'input_gate_param.dart';

class InputDropdownParam extends InputGateParam {
  final String type;

  const InputDropdownParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
    required this.type,
  });

  factory InputDropdownParam.fromInputGate({
    required InputGateParam inputGate,
    required String typeName,
  }) {
    return InputDropdownParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
      type: typeName,
    );
  }
}
