import '../enums/ds_mode.dart';
import 'feature_param.dart';

class DsParam extends FeatureParam {
  final DsMode mode;

  const DsParam({
    required this.mode,
    required super.featureName,
    required super.moduleName,
    required super.workspaceName,
    required super.workspacePath,
  });
}
