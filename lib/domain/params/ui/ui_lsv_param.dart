import 'ui_gate_param.dart';

class UiLsvParam extends UiGateParam {
  const UiLsvParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
    required super.model,
  });

  factory UiLsvParam.fromUiGate(UiGateParam ui) {
    return UiLsvParam(
      featureName: ui.featureName,
      featurePath: ui.featurePath,
      moduleName: ui.moduleName,
      modulePath: ui.modulePath,
      slice: ui.slice,
      model: ui.model,
    );
  }
}
