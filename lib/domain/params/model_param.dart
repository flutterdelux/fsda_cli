import '../enums/model_type.dart';
import '../models/prop_model.dart';
import 'feature_gate_param.dart';

class ModelParam extends FeatureGateParam {
  final String name;
  final String path;
  final ModelType type;
  final List<PropModel> props;
  final bool isInjectL10n;

  const ModelParam({
    required this.name,
    required this.path,
    required this.type,
    required this.props,
    this.isInjectL10n = false,
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
  });

  factory ModelParam.fromFeatureGate({
    required FeatureGateParam featureGate,
    required String name,
    required String path,
    required ModelType type,
    required List<PropModel> props,
    required bool isInjectL10n,
  }) {
    return ModelParam(
      name: name,
      path: path,
      type: type,
      props: props,
      featureName: featureGate.featureName,
      featurePath: featureGate.featurePath,
      moduleName: featureGate.moduleName,
      modulePath: featureGate.modulePath,
      isInjectL10n: isInjectL10n,
    );
  }
}
