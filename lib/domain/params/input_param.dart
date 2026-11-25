import '../enums/input_type.dart';
import 'feature_param.dart';

class InputParam extends FeatureParam {
  final InputType type;
  final String field;
  final String? dataType;
  final int minLines;
  final int maxLines;
  final bool isList;

  const InputParam({
    required this.type,
    required this.field,
    this.dataType,
    this.minLines = 3,
    this.maxLines = 3,
    this.isList = false,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory InputParam.fromFeature({
    required FeatureParam feature,
    required InputType type,
    required String field,
    String? dataType,
    int minLines = 3,
    int maxLines = 3,
    bool isList = false,
  }) {
    return InputParam(
      type: type,
      field: field,
      dataType: dataType,
      minLines: minLines,
      maxLines: maxLines,
      isList: isList,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
