import 'input_gate_param.dart';

class InputTextAreaParam extends InputGateParam {
  final int minLines;
  final int maxLines;

  const InputTextAreaParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.field,
    this.minLines = 3,
    this.maxLines = 3,
  });

  factory InputTextAreaParam.fromInputGate({
    required InputGateParam inputGate,
    int minLines = 3,
    int maxLines = 3,
  }) {
    return InputTextAreaParam(
      featureName: inputGate.featureName,
      featurePath: inputGate.featurePath,
      moduleName: inputGate.moduleName,
      modulePath: inputGate.modulePath,
      field: inputGate.field,
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}
