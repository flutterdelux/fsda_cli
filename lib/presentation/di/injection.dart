import 'package:get_it/get_it.dart';

import '../../infrastructure/services/app_service.dart';
import '../../infrastructure/services/apply_service.dart';
import '../../infrastructure/services/compose_service.dart';
import '../../infrastructure/services/configure_app_service.dart';
import '../../infrastructure/services/data_source_service.dart';
import '../../infrastructure/services/enum_service.dart';
import '../../infrastructure/services/failure_service.dart';
import '../../infrastructure/services/feature_service.dart';
import '../../infrastructure/services/helpers/arb_service.dart';
import '../../infrastructure/services/helpers/config_service.dart';
import '../../infrastructure/services/helpers/directory_service.dart';
import '../../infrastructure/services/helpers/export_service.dart';
import '../../infrastructure/services/helpers/file_finder_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/helpers/import_resolver_service.dart';
import '../../infrastructure/services/helpers/import_service.dart';
import '../../infrastructure/services/helpers/logic_uc_service.dart';
import '../../infrastructure/services/helpers/mason_generator_service.dart';
import '../../infrastructure/services/helpers/method_service.dart';
import '../../infrastructure/services/helpers/operation_report_service.dart';
import '../../infrastructure/services/helpers/process_service.dart';
import '../../infrastructure/services/input_service.dart';
import '../../infrastructure/services/logic_service.dart';
import '../../infrastructure/services/maintenance/build_runner_service.dart';
import '../../infrastructure/services/maintenance/fix_import_service.dart';
import '../../infrastructure/services/maintenance/l10n_service.dart';
import '../../infrastructure/services/maintenance/rebuild_service.dart';
import '../../infrastructure/services/maintenance/refresh_service.dart';
import '../../infrastructure/services/model_service.dart';
import '../../infrastructure/services/module_service.dart';
import '../../infrastructure/services/package_sync_service.dart';
import '../../infrastructure/services/plan_service.dart';
import '../../infrastructure/services/reg_feature_service.dart';
import '../../infrastructure/services/reg_module_service.dart';
import '../../infrastructure/services/run_service.dart';
import '../../infrastructure/services/sequence_service.dart';
import '../../infrastructure/services/ui_service.dart';
import '../../infrastructure/services/workspace_service.dart';
import '../cli_logger.dart';

final sl = GetIt.instance;

void configureDependencies() {
  // Helpers
  sl.registerLazySingleton<CliLogger>(() => CliLogger());
  sl.registerLazySingleton<ProcessService>(() => ProcessService());
  sl.registerLazySingleton<OperationReportService>(
    () => OperationReportService(directoryService: sl()),
  );
  sl.registerLazySingleton<ConfigService>(
    () => ConfigService(directoryService: sl(), fileService: sl()),
  );
  sl.registerLazySingleton<ExportService>(
    () => ExportService(fileService: sl()),
  );
  sl.registerLazySingleton<DirectoryService>(() => DirectoryService());
  sl.registerLazySingleton<FileService>(() => FileService());
  sl.registerLazySingleton<ArbService>(
    () => ArbService(directoryService: sl(), fileService: sl()),
  );
  sl.registerLazySingleton<ImportService>(
    () => ImportService(fileService: sl()),
  );
  sl.registerLazySingleton<MethodService>(
    () => MethodService(fileService: sl()),
  );
  sl.registerLazySingleton<LogicUcService>(
    () => LogicUcService(fileService: sl()),
  );
  sl.registerLazySingleton<FileFinderService>(
    () => FileFinderService(fileService: sl(), directoryService: sl()),
  );
  sl.registerLazySingleton<ImportResolverService>(
    () => ImportResolverService(fileService: sl(), fileFinderService: sl()),
  );
  sl.registerLazySingleton<MasonGeneratorService>(
    () => MasonGeneratorService(directoryService: sl(), reportService: sl()),
  );

  // Maintenance
  sl.registerLazySingleton<BuildRunnerService>(
    () => BuildRunnerService(processService: sl()),
  );
  sl.registerLazySingleton<L10nService>(
    () => L10nService(processService: sl()),
  );
  sl.registerLazySingleton<RebuildService>(
    () => RebuildService(buildRunnerService: sl(), l10nService: sl()),
  );
  sl.registerLazySingleton<RefreshService>(
    () => RefreshService(processService: sl()),
  );
  sl.registerLazySingleton<FixImportService>(
    () => FixImportService(processService: sl<ProcessService>()),
  );
  sl.registerLazySingleton<PackageSyncService>(
    () => PackageSyncService(
      configService: sl(),
      reportService: sl(),
      processService: sl(),
      directoryService: sl(),
      fileService: sl(),
    ),
  );

  // Generator
  sl.registerLazySingleton<WorkspaceService>(
    () => WorkspaceService(
      reportService: sl(),
      directoryService: sl(),
      fileService: sl(),
    ),
  );

  sl.registerLazySingleton<AppService>(
    () => AppService(
      configService: sl<ConfigService>(),
      processService: sl<ProcessService>(),
      reportService: sl<OperationReportService>(),
      directoryService: sl(),
      fileService: sl(),
      generatorService: sl(),
    ),
  );
  sl.registerLazySingleton<ConfigureAppService>(
    () => ConfigureAppService(
      configService: sl(),
      processService: sl(),
      reportService: sl(),
      directoryService: sl(),
      fileService: sl(),
      importService: sl(),
    ),
  );

  sl.registerLazySingleton<ModuleService>(
    () => ModuleService(
      configService: sl<ConfigService>(),
      processService: sl<ProcessService>(),
      reportService: sl<OperationReportService>(),
      directoryService: sl(),
      buildRunnerService: sl(),
      l10nService: sl(),
      masonGeneratorService: sl(),
    ),
  );
  sl.registerLazySingleton<FeatureService>(
    () => FeatureService(
      reportService: sl(),
      directoryService: sl(),
      exportService: sl(),
      arbService: sl(),
      fileService: sl(),
    ),
  );
  sl.registerLazySingleton<FailureService>(
    () => FailureService(
      reportService: sl(),
      arbService: sl(),
      fileService: sl(),
    ),
  );

  // Data Source
  sl.registerLazySingleton<DataSourceService>(
    () => DataSourceService(
      reportService: sl(),
      exportService: sl(),
      fileService: sl(),
      importService: sl(),
    ),
  );

  // Enum
  sl.registerLazySingleton<EnumService>(
    () => EnumService(
      reportService: sl(),
      exportService: sl(),
      arbService: sl(),
      fileService: sl(),
      directoryService: sl(),
    ),
  );

  // Model
  sl.registerLazySingleton<ModelService>(
    () => ModelService(
      reportService: sl(),
      exportService: sl(),
      arbService: sl(),
      fileService: sl(),
      importResolverService: sl(),
      importService: sl(),
    ),
  );

  // Sequence
  sl.registerLazySingleton<SequenceService>(
    () => SequenceService(
      exportService: sl(),
      arbService: sl(),
      fileService: sl(),
      reportService: sl(),
      importService: sl(),
      methodService: sl(),
      importResolverService: sl(),
    ),
  );

  // Logic
  sl.registerLazySingleton<LogicService>(
    () => LogicService(
      fileService: sl(),
      reportService: sl(),
      importService: sl(),
      importResolverService: sl(),
      exportService: sl(),
      logicUcService: sl(),
    ),
  );

  // Input
  sl.registerLazySingleton<InputService>(
    () => InputService(
      fileService: sl(),
      reportService: sl(),
      arbService: sl(),
      importResolverService: sl(),
      importService: sl(),
    ),
  );

  // UI
  sl.registerLazySingleton<UiService>(
    () => UiService(
      fileService: sl(),
      reportService: sl(),
      arbService: sl(),
      importResolverService: sl(),
      importService: sl(),
      exportService: sl(),
      fileFinderService: sl(),
    ),
  );

  sl.registerLazySingleton<RegModuleService>(
    () => RegModuleService(
      fileService: sl(),
      reportService: sl(),
      importService: sl(),
      refreshService: sl(),
    ),
  );
  sl.registerLazySingleton<RegFeatureService>(
    () => RegFeatureService(
      fileService: sl(),
      reportService: sl(),
      directoryService: sl(),
    ),
  );

  sl.registerLazySingleton<ComposeService>(
    () => ComposeService(
      fileService: sl(),
      reportService: sl(),
      directoryService: sl(),
      fileFinderService: sl(),
      modelService: sl(),
      importService: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => PlanService(fileService: sl(), reportService: sl()),
  );
  sl.registerLazySingleton(
    () => ApplyService(
      fileService: sl(),
      reportService: sl(),
      directoryService: sl(),
      moduleService: sl(),
      featureService: sl(),
      failureService: sl(),
      dataSourceService: sl(),
      enumService: sl(),
      modelService: sl(),
      sequenceService: sl(),
      logicService: sl(),
      inputService: sl(),
      uiService: sl(),
      composeService: sl(),
      appService: sl(),
      configureAppService: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => RunService(processService: sl(), fileService: sl()),
  );
}
