import 'package:path/path.dart' as p;

import '../../domain/models/plan_model.dart';
import '../constants/cli_info.dart';

extension PlanModelX on PlanModel {
  String get workspacePath => switch (this) {
    AppPlanModel(:final app) => app.workspacePath,
    ModulePlanModel(:final module) => module.workspacePath,
    FeaturePlanModel(:final feature) => feature.workspacePath,
    SlicePlanModel(:final slice) => slice.workspacePath,
  };

  String get plansDirPath =>
      p.join(workspacePath, CliInfo.fsdaDirName, CliInfo.plansDirName);

  String get planPath => switch (this) {
    AppPlanModel(:final app) => p.join(
      plansDirPath,
      'apps',
      '${app.appName}.yaml',
    ),
    ModulePlanModel(:final module) => p.join(
      plansDirPath,
      'modules',
      module.moduleName,
      'index.yaml',
    ),
    FeaturePlanModel(:final feature) => p.join(
      plansDirPath,
      'modules',
      feature.moduleName,
      'features',
      feature.featureName,
      'index.yaml',
    ),
    SlicePlanModel(:final slice) => p.join(
      plansDirPath,
      'modules',
      slice.moduleName,
      'features',
      slice.featureName,
      '${slice.sliceName}.yaml',
    ),
  };
}
