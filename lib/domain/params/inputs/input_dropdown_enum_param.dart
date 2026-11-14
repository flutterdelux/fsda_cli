import 'input_gate_param.dart';

class InputDropdownEnumParam extends InputGateParam {
  final String type;

  const InputDropdownEnumParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
    required this.type,
  });

  factory InputDropdownEnumParam.fromInputGate({
    required InputGateParam inputGate,
    required String enumType,
  }) {
    return InputDropdownEnumParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
      type: enumType,
    );
  }
}
