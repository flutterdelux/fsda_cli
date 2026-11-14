import 'ui_gate_param.dart';

class UiParam extends UiGateParam {
  const UiParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
    required super.model,
  });

  factory UiParam.fromUiGate(UiGateParam ui) {
    return UiParam(
      featureName: ui.featureName,
      featurePath: ui.featurePath,
      moduleName: ui.moduleName,
      modulePath: ui.modulePath,
      slice: ui.slice,
      model: ui.model,
    );
  }
}
