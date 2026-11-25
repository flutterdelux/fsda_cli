import '../../core/extensions/plan_model_x.dart';
import '../../domain/models/plan_model.dart';
import '../templates/plan/app_plan_template.dart';
import '../templates/plan/feature_plan_template.dart';
import '../templates/plan/module_plan_template.dart';
import '../templates/plan/slice_plan_template.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';

class PlanService {
  final FileService _fileService;
  final OperationReportService _reportService;

  const PlanService({
    required FileService fileService,
    required OperationReportService reportService,
  }) : _fileService = fileService,
       _reportService = reportService;

  Future<bool> exists(PlanModel plan) {
    return _fileService.exists(plan.planPath);
  }

  Future<String> generate({
    required PlanModel plan,
    required void Function(String msg) onProgress,
    bool isExample = false,
  }) async {
    final targetPath = plan.planPath;

    onProgress('Building declarative YAML template...');
    final content = switch (plan) {
      AppPlanModel(:final app) => AppPlanTemplate.build(
        appName: app.appName,
        isExample: isExample,
      ),
      ModulePlanModel(:final module) => ModulePlanTemplate.build(
        moduleName: module.moduleName,
        isExample: isExample,
      ),
      FeaturePlanModel(:final feature) => FeaturePlanTemplate.build(
        moduleName: feature.moduleName,
        featureName: feature.featureName,
        isExample: isExample,
      ),
      SlicePlanModel(:final slice) => SlicePlanTemplate.build(
        moduleName: slice.moduleName,
        featureName: slice.featureName,
        sliceName: slice.sliceName,
        isExample: isExample,
      ),
    };

    onProgress('Writing plan file...');
    await _fileService.writeAsString(path: targetPath, content: content);
    _reportService.addCreated(targetPath);

    return targetPath;
  }
}
