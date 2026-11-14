import 'input_gate_param.dart';

class InputSelectorParam extends InputGateParam {
  final String valueType;
  final bool isList;

  const InputSelectorParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
    required this.valueType,
    this.isList = false,
  });

  factory InputSelectorParam.fromInputGate({
    required InputGateParam inputGate,
    required String valueType,
    bool isList = false,
  }) {
    return InputSelectorParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
      valueType: valueType,
      isList: isList,
    );
  }
}
