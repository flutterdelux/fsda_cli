import 'feature_param.dart';

class EnumParam extends FeatureParam {
  /// e.g. task_status
  final String enumName;

  /// e.g. todo, in_progress, completed
  final List<String> values;
  final bool isLower;

  const EnumParam({
    required this.enumName,
    required this.values,
    required this.isLower,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory EnumParam.fromFeature({
    required FeatureParam feature,
    required String enumName,
    required List<String> values,
    required bool isLower,
  }) {
    return EnumParam(
      enumName: enumName,
      values: values,
      isLower: isLower,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
