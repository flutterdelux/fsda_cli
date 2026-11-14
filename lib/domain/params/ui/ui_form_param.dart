import '../../models/form_field_model.dart';
import 'ui_gate_param.dart';

class UiFormParam extends UiGateParam {
  final List<FormFieldModel> fields;
  final bool hasInitial;

  const UiFormParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required super.slice,
    required super.model,
    required this.fields,
    this.hasInitial = false,
  });

  factory UiFormParam.fromUiGate({
    required UiGateParam ui,
    required List<FormFieldModel> fields,
    bool hasInitial = false,
  }) {
    return UiFormParam(
      featureName: ui.featureName,
      featurePath: ui.featurePath,
      moduleName: ui.moduleName,
      modulePath: ui.modulePath,
      slice: ui.slice,
      model: ui.model,
      fields: fields,
      hasInitial: hasInitial,
    );
  }
}
