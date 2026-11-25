import '../enums/ui_type.dart';
import '../models/form_field_model.dart';
import 'slice_param.dart';

class UiParam extends SliceParam {
  final UiType type;
  final String model;
  final List<FormFieldModel>? fields;
  final bool hasInitial;

  const UiParam({
    this.type = UiType.standard,
    required this.model,
    this.fields,
    this.hasInitial = false,
    required super.sliceName,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory UiParam.fromSlice({
    required SliceParam slice,
    UiType type = UiType.standard,
    required String model,
    List<FormFieldModel>? fields,
    bool hasInitial = false,
  }) {
    return UiParam(
      type: type,
      model: model,
      fields: fields,
      hasInitial: hasInitial,
      featureName: slice.featureName,
      moduleName: slice.moduleName,
      sliceName: slice.sliceName,
      workspaceName: slice.workspaceName,
      workspacePath: slice.workspacePath,
    );
  }
}
