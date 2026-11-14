import 'ui_gate_param.dart';

class UiPagParam extends UiGateParam {
  const UiPagParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
    required super.model,
  });

  factory UiPagParam.fromUiGate(UiGateParam ui) {
    return UiPagParam(
      featureName: ui.featureName,
      featurePath: ui.featurePath,
      moduleName: ui.moduleName,
      modulePath: ui.modulePath,
      slice: ui.slice,
      model: ui.model,
    );
  }
}
