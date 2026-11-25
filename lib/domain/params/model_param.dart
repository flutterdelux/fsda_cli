import '../enums/model_type.dart';
import '../models/prop_model.dart';
import 'feature_param.dart';

class ModelParam extends FeatureParam {
  /// e.g. task_entity, task_dto, task_create_param
  final String modelName;
  final ModelType type;
  final List<PropModel> props;
  final bool isL10n;

  const ModelParam({
    required this.modelName,
    required this.type,
    required this.props,
    this.isL10n = false,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });

  factory ModelParam.fromFeature({
    required FeatureParam feature,
    required String modelName,
    required ModelType type,
    required List<PropModel> props,
    required bool isL10n,
  }) {
    return ModelParam(
      modelName: modelName,
      type: type,
      props: props,
      isL10n: isL10n,
      featureName: feature.featureName,
      moduleName: feature.moduleName,
      workspaceName: feature.workspaceName,
      workspacePath: feature.workspacePath,
    );
  }
}
