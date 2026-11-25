import '../../core/extensions/app_param_x.dart';
import '../../core/extensions/compose_param_x.dart';
import '../../core/extensions/ds_param_x.dart';
import '../../core/extensions/enum_param_x.dart';
import '../../core/extensions/feature_param_x.dart';
import '../../core/extensions/input_param_x.dart';
import '../../core/extensions/model_param_x.dart';
import '../../core/extensions/module_param_x.dart';
import '../../core/extensions/slice_param_x.dart';
import '../../domain/models/plan_model.dart';
import '../../domain/params/app_param.dart';
import '../../domain/params/ds_param.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/gen_app_param.dart';
import '../../domain/params/input_param.dart';
import '../../domain/params/local_ds_param.dart';
import '../../domain/params/logic_flow_param.dart';
import '../../domain/params/logic_param.dart';
import '../../domain/params/model_param.dart';
import '../../domain/params/module_param.dart';
import '../../domain/params/remote_ds_param.dart';
import '../../domain/params/sequence_param.dart';
import '../../domain/params/ui_param.dart';
import '../text_modifiers/string_extension.dart';
import 'app_service.dart';
import 'compose_service.dart';
import 'configure_app_service.dart';
import 'data_source_service.dart';
import 'enum_service.dart';
import 'failure_service.dart';
import 'feature_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';
import 'input_service.dart';
import 'logic_service.dart';
import 'model_service.dart';
import 'module_service.dart';
import 'sequence_service.dart';
import 'ui_service.dart';

class ApplyService {
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final FileService _fileService;
  final AppService _appService;
  final ConfigureAppService _configureAppService;
  final ModuleService _moduleService;
  final FeatureService _featureService;
  final FailureService _failureService;
  final DataSourceService _dataSourceService;
  final EnumService _enumService;
  final ModelService _modelService;
  final SequenceService _sequenceService;
  final LogicService _logicService;
  final InputService _inputService;
  final UiService _uiService;
  final ComposeService _composeService;

  const ApplyService({
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required FileService fileService,
    required AppService appService,
    required ConfigureAppService configureAppService,
    required ModuleService moduleService,
    required FeatureService featureService,
    required FailureService failureService,
    required DataSourceService dataSourceService,
    required EnumService enumService,
    required ModelService modelService,
    required SequenceService sequenceService,
    required LogicService logicService,
    required InputService inputService,
    required UiService uiService,
    required ComposeService composeService,
  }) : _reportService = reportService,
       _directoryService = directoryService,
       _fileService = fileService,
       _appService = appService,
       _configureAppService = configureAppService,
       _moduleService = moduleService,
       _featureService = featureService,
       _failureService = failureService,
       _dataSourceService = dataSourceService,
       _enumService = enumService,
       _modelService = modelService,
       _sequenceService = sequenceService,
       _logicService = logicService,
       _inputService = inputService,
       _uiService = uiService,
       _composeService = composeService;

  Future<void> apply({
    required PlanModel plan,
    required void Function(String msg) onProgress,
  }) async {
    switch (plan) {
      case AppPlanModel():
        await _applyAppPlan(plan, onProgress);
      case ModulePlanModel():
        await _applyModulePlan(plan, onProgress);
      case FeaturePlanModel():
        await _applyFeatureSections(
          feature: plan.feature,
          datasources: plan.datasources,
          enums: plan.enums,
          models: plan.models,
          sequences: plan.sequences,
          logics: plan.logics,
          logicFlows: plan.logicFlows,
          inputs: plan.inputs,
          uis: plan.uis,
          onProgress: onProgress,
        );
      case SlicePlanModel():
        await _applyFeatureSections(
          feature: plan.slice,
          datasources: plan.datasources,
          enums: plan.enums,
          models: plan.models,
          sequences: plan.sequences,
          logics: plan.logics,
          logicFlows: plan.logicFlows,
          inputs: plan.inputs,
          uis: plan.uis,
          onProgress: onProgress,
        );
    }
  }

  // ==================== App Compose Plan ====================
  Future<void> _applyAppPlan(
    AppPlanModel plan,
    void Function(String) onProgress,
  ) async {
    await _ensureAppExists(plan.app, onProgress);

    for (final item in plan.composes) {
      if (await _fileService.exists(item.targetPath)) {
        _reportService.addSkipped(item.targetPath);
        continue;
      }
      await _composeService.compose(param: item, onProgress: onProgress);
    }
  }

  // ==================== Module Plan ====================
  Future<void> _applyModulePlan(
    ModulePlanModel plan,
    void Function(String) onProgress,
  ) async {
    await _ensureModuleExists(plan.module, onProgress);

    if (plan.failures.isNotEmpty) {
      onProgress('Generating module failures...');
      for (final failure in plan.failures) {
        await _failureService.generate(
          failureParam: failure,
          onProgress: onProgress,
        );
      }
    }
  }

  // ==================== Feature & Slice Plan ====================
  Future<void> _applyFeatureSections({
    required FeatureParam feature,
    required List<DsParam> datasources,
    required List<EnumParam> enums,
    required List<ModelParam> models,
    required List<SequenceParam> sequences,
    required List<LogicParam> logics,
    required List<LogicFlowParam> logicFlows,
    required List<InputParam> inputs,
    required List<UiParam> uis,
    required void Function(String) onProgress,
  }) async {
    await _ensureModuleExists(feature, onProgress);
    await _ensureFeatureExists(feature, onProgress);

    // 1. Datasources
    for (final ds in datasources) {
      if (await _fileService.exists(ds.implPath)) {
        _reportService.addSkipped(ds.implPath);
        continue;
      }
      await switch (ds.mode) {
        .local => _dataSourceService.generateLocalDataSource(
          localDs: ds as LocalDsParam,
          onProgress: onProgress,
        ),
        .remote => _dataSourceService.generateRemoteDataSource(
          remoteDs: ds as RemoteDsParam,
          onProgress: onProgress,
        ),
      };
    }

    // 2. Enums
    for (final item in enums) {
      if (await _fileService.exists(item.enumPath)) {
        _reportService.addSkipped(item.enumPath);
        continue;
      }
      await _enumService.generate(enumParam: item, onProgress: onProgress);
    }

    // 3. Models
    for (final item in models) {
      if (await _fileService.exists(item.modelPath)) {
        _reportService.addSkipped(item.modelPath);
        continue;
      }
      await _modelService.generate(model: item, onProgress: onProgress);
    }

    // 4. Sequences
    for (final item in sequences) {
      await _sequenceService.generate(sequence: item, onProgress: onProgress);
    }

    // 5. Logic (state)
    for (final item in logics) {
      if (await _directoryService.exists(item.logicSlicePath)) {
        _reportService.addSkipped(item.logicSlicePath);
        continue;
      }
      await _logicService.generate(logic: item, onProgress: onProgress);
    }

    // 6. Logic Flows
    for (final item in logicFlows) {
      if (await _directoryService.exists(item.logicSlicePath)) {
        _reportService.addSkipped(item.logicSlicePath);
        continue;
      }
      await _logicService.generateFlow(logic: item, onProgress: onProgress);
    }

    // 7. Inputs
    for (final item in inputs) {
      if (await _fileService.exists(item.widgetPath)) {
        _reportService.addSkipped(item.widgetPath);
        continue;
      }
      await _inputService.generate(input: item, onProgress: onProgress);
    }

    // 8. UIs
    for (final item in uis) {
      if (await _directoryService.exists(item.uiSlicePath)) {
        _reportService.addSkipped(item.uiSlicePath);
        continue;
      }
      await _uiService.generate(ui: item, onProgress: onProgress);
    }
  }

  // ==================== Auto-Create Parents ====================
  Future<void> _ensureAppExists(
    AppParam app,
    void Function(String) onProgress,
  ) async {
    if (await _directoryService.exists(app.appPath)) return;
    onProgress('Auto-creating app "${app.appName}"...');
    await _appService.generate(
      genApp: GenAppParam.fromApp(
        app: app,
        appTitle: app.appName.titleCase,
        org: 'com.example',
        orgName: 'Example',
      ),
      onProgress: onProgress,
    );

    onProgress('Auto-configure app "${app.appName}"...');
    await _configureAppService.configure(app: app, onProgress: onProgress);
  }

  Future<void> _ensureModuleExists(
    ModuleParam module,
    void Function(String) onProgress,
  ) async {
    if (await _directoryService.exists(module.modulePath)) return;
    onProgress('Auto-creating module "${module.moduleName}"...');
    await _moduleService.generate(module: module, onProgress: onProgress);
  }

  Future<void> _ensureFeatureExists(
    FeatureParam feature,
    void Function(String) onProgress,
  ) async {
    if (await _directoryService.exists(feature.featurePath)) return;
    onProgress('Auto-creating feature "${feature.featureName}"...');
    await _featureService.generate(feature: feature, onProgress: onProgress);
  }
}
