import 'ui_gate_param.dart';

class UiLshParam extends UiGateParam {
  const UiLshParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
    required super.model,
  });

  factory UiLshParam.fromUiGate(UiGateParam ui) {
    return UiLshParam(
      featureName: ui.featureName,
      featurePath: ui.featurePath,
      moduleName: ui.moduleName,
      modulePath: ui.modulePath,
      slice: ui.slice,
      model: ui.model,
    );
  }
}
