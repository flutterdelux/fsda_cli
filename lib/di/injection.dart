import 'package:args/command_runner.dart';
import 'package:get_it/get_it.dart';

import '../commands/composition/compose_action_command.dart';
import '../commands/composition/compose_dialog_command.dart';
import '../commands/composition/compose_form_command.dart';
import '../commands/composition/compose_form_dialog_command.dart';
import '../commands/composition/compose_main_command.dart';
import '../commands/composition/compose_pag_command.dart';
import '../commands/composition/compose_pmi_command.dart';
import '../commands/composition/compose_sec_command.dart';
import '../commands/generation/gen_app_command.dart';
import '../commands/generation/gen_feature_command.dart';
import '../commands/generation/gen_module_command.dart';
import '../commands/generation/regen_feature_command.dart';
import '../commands/input/input_dropdown_command.dart';
import '../commands/input/input_dropdown_enum_command.dart';
import '../commands/input/input_image_command.dart';
import '../commands/input/input_number_command.dart';
import '../commands/input/input_password_command.dart';
import '../commands/input/input_qty_command.dart';
import '../commands/input/input_selector_command.dart';
import '../commands/input/input_selector_list_command.dart';
import '../commands/input/input_switch_command.dart';
import '../commands/input/input_text_area_command.dart';
import '../commands/input/input_text_command.dart';
import '../commands/maintenance/cp_ui_command.dart';
import '../commands/maintenance/di_command.dart';
import '../commands/maintenance/fix_import_command.dart';
import '../commands/maintenance/rebuild_command.dart';
import '../commands/maintenance/refresh_command.dart';
import '../commands/maintenance/reg_command.dart';
import '../commands/maintenance/rm_feature_command.dart';
import '../commands/maintenance/rm_reg_command.dart';
import '../commands/modelling/dto_command.dart';
import '../commands/modelling/entity_command.dart';
import '../commands/modelling/entity_dto_command.dart';
import '../commands/modelling/enum_command.dart';
import '../commands/modelling/param_command.dart';
import '../commands/modelling/param_request_command.dart';
import '../commands/modelling/request_command.dart';
import '../commands/slice/slice_m_command.dart';
import '../commands/slice/slice_mp_command.dart';
import '../commands/slice/slice_mr_command.dart';
import '../commands/slice/slice_mrp_command.dart';
import '../commands/slice/slice_r_command.dart';
import '../commands/slice/slice_rof_command.dart';
import '../commands/slice/slice_rp_command.dart';
import '../commands/slice/slice_rpag_command.dart';
import '../commands/slice/slice_rs_command.dart';
import '../commands/slice/slice_rsp_command.dart';
import '../commands/ui/ui_action_command.dart';
import '../commands/ui/ui_dialog_command.dart';
import '../commands/ui/ui_form_command.dart';
import '../commands/ui/ui_form_dialog_command.dart';
import '../commands/ui/ui_lsh_command.dart';
import '../commands/ui/ui_lsv_command.dart';
import '../commands/ui/ui_main_command.dart';
import '../commands/ui/ui_pag_command.dart';
import '../commands/ui/ui_pmi_command.dart';
import '../commands/ui/ui_sec_command.dart';
import '../commands/workspace/configure_app_command.dart';
import '../commands/workspace/configure_command.dart';
import '../commands/workspace/create_command.dart';
import '../commands/workspace/list_pckg_command.dart';
import '../generators/app_generator.dart';
import '../generators/composition/compose_generator.dart';
import '../generators/configure_app/app_dependency_installer.dart';
import '../generators/configure_app/di_file_sync_service.dart';
import '../generators/configure_app/infra_spec_bundle_reader.dart';
import '../generators/configure_app/managed_package_dependency_sync.dart';
import '../generators/configure_app_generator.dart';
import '../generators/configure_generator.dart';
import '../generators/cp_ui_generator.dart';
import '../generators/di_generator.dart';
import '../generators/enum_generator.dart';
import '../generators/feature_generator.dart';
import '../generators/input/input_generator.dart';
import '../generators/input/services/input_arb_entry_builder_service.dart';
import '../generators/input/services/input_widget_file_builder_service.dart';
import '../generators/modelling/dto_generator.dart';
import '../generators/modelling/entity_dto_generator.dart';
import '../generators/modelling/entity_generator.dart';
import '../generators/modelling/param_generator.dart';
import '../generators/modelling/param_request_generator.dart';
import '../generators/modelling/request_generator.dart';
import '../generators/module_generator.dart';
import '../generators/package_generator.dart';
import '../generators/rebuild_generator.dart';
import '../generators/refresh_generator.dart';
import '../generators/reg_module_generator.dart';
import '../generators/rm_feature_generator.dart';
import '../generators/rm_reg_module_generator.dart';
import '../generators/slice_generator.dart';
import '../generators/ui_generator.dart';
import '../generators/workspace_generator.dart';
import '../services/bundle_service.dart';
import '../services/command_operation_service.dart';
import '../services/file_service.dart';
import '../services/hook_service.dart';
import '../services/l10n/arb_injector_service.dart';
import '../services/logger_service.dart';
import '../services/operation_report_service.dart';
import '../services/process_service.dart';
import '../services/pubspec_service.dart';
import '../services/sdk_service.dart';
import '../services/slices/slice_checkpoint_weaver_service.dart'
    show SliceCheckpointWeaverService;
import '../services/slices/slice_manifest_render_service.dart';
import '../services/slices/slice_service.dart';
import '../services/slices/slice_source_normalizer_service.dart';
import '../services/ui/ui_form_service.dart';
import '../services/workspace_service.dart';
// Import semua services, generators, dan commands Anda di sini...

final sl = GetIt.instance;

void configureDependencies() {
  // --------------------------------------------------
  // 1. Register Services
  // --------------------------------------------------
  sl.registerLazySingleton(() => SdkService());
  sl.registerLazySingleton(() => LoggerService());
  sl.registerLazySingleton(() => ProcessService());
  sl.registerLazySingleton(
    () => PubspecService(processService: sl(), logger: sl()),
  );
  sl.registerLazySingleton(() => FileService(sdkService: sl()));
  sl.registerLazySingleton(() => HookService(processService: sl()));
  sl.registerLazySingleton(() => BundleService(fileService: sl()));
  sl.registerLazySingleton(() => WorkspaceService());
  sl.registerLazySingleton(() => OperationReportService());
  sl.registerLazySingleton(
    () =>
        CommandOperationService(hookService: sl(), logger: sl(), report: sl()),
  );
  sl.registerLazySingleton(() => ArbInjectorService(logger: sl()));
  sl.registerLazySingleton(() => const InputArbEntryBuilderService());
  sl.registerLazySingleton(() => const InputWidgetFileBuilderService());
  sl.registerLazySingleton(() => const UiFormService());

  // --------------------------------------------------
  // Configure App Services
  // --------------------------------------------------
  sl.registerLazySingleton(() => AppDependencyInstaller(pubspecService: sl()));
  sl.registerLazySingleton(() => DiFileSyncService(logger: sl()));
  sl.registerLazySingleton(() => const InfraSpecBundleReader());
  sl.registerLazySingleton(() => const ManagedPackageDependencySync());

  // --------------------------------------------------
  // Slice Services
  // --------------------------------------------------
  sl.registerLazySingleton(() => SliceCheckpointWeaverService(logger: sl()));
  sl.registerLazySingleton(() => const SliceManifestRenderService());
  sl.registerLazySingleton(
    () => SliceService(
      logger: sl(),
      fileService: sl(),
      report: sl(),
      manifestRenderService: sl(),
      sourceNormalizerService: sl(),
      checkpointWeaverService: sl(),
    ),
  );
  sl.registerLazySingleton(() => const SliceSourceNormalizerService());

  // --------------------------------------------------
  // Register Generators
  // --------------------------------------------------
  sl.registerLazySingleton(
    () => WorkspaceGenerator(logger: sl(), report: sl()),
  );
  sl.registerLazySingleton(
    () => PackageGenerator(
      logger: sl(),
      pubspecService: sl(),
      fileService: sl(),
      bundleService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ConfigureGenerator(logger: sl(), packageGenerator: sl()),
  );
  sl.registerLazySingleton(
    () => AppGenerator(
      logger: sl(),
      pubspecService: sl(),
      processService: sl(),
      sdkService: sl(),
      report: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ModuleGenerator(
      logger: sl(),
      sdkService: sl(),
      report: sl(),
      pubspecService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => FeatureGenerator(logger: sl(), report: sl(), fileService: sl()),
  );

  // --------------------------------------------------
  // Register Medelling
  // --------------------------------------------------
  sl.registerLazySingleton(
    () => EnumGenerator(
      logger: sl(),
      report: sl(),
      arbInjectorService: sl(),
      fileService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => DtoGenerator(logger: sl(), report: sl(), fileService: sl()),
  );
  sl.registerLazySingleton(
    () => EntityGenerator(logger: sl(), report: sl(), fileService: sl()),
  );
  sl.registerLazySingleton(
    () => ParamGenerator(logger: sl(), report: sl(), fileService: sl()),
  );
  sl.registerLazySingleton(
    () => RequestGenerator(logger: sl(), report: sl(), fileService: sl()),
  );
  sl.registerLazySingleton(
    () => ParamRequestGenerator(logger: sl(), report: sl(), fileService: sl()),
  );
  sl.registerLazySingleton(
    () => EntityDtoGenerator(logger: sl(), report: sl(), fileService: sl()),
  );

  // --------------------------------------------------
  // Register Slice
  // --------------------------------------------------
  sl.registerLazySingleton(
    () => SliceGenerator(
      logger: sl(),
      fileService: sl(),
      report: sl(),
      sliceService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => InputGenerator(
      logger: sl(),
      arbInjectorService: sl(),
      widgetFileBuilderService: sl(),
      arbEntryBuilderService: sl(),
      fileService: sl(),
      report: sl(),
      commandOperationService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => UiGenerator(
      logger: sl(),
      report: sl(),
      fileService: sl(),
      arbInjectorService: sl(),
      uiFormService: sl(),
    ),
  );

  // --------------------------------------------------
  // Register Maintenance
  // --------------------------------------------------
  sl.registerLazySingleton(
    () => RegModuleGenerator(logger: sl(), report: sl(), fileService: sl()),
  );
  sl.registerLazySingleton(
    () => RmRegModuleGenerator(logger: sl(), report: sl()),
  );
  sl.registerLazySingleton(
    () => RmFeatureGenerator(logger: sl(), report: sl()),
  );
  sl.registerLazySingleton(() => CpUiGenerator(logger: sl(), report: sl()));
  sl.registerLazySingleton(
    () => RebuildGenerator(logger: sl(), hookService: sl()),
  );
  sl.registerLazySingleton(
    () => RefreshGenerator(logger: sl(), hookService: sl()),
  );
  sl.registerLazySingleton(() => DiGenerator(logger: sl(), report: sl()));
  sl.registerLazySingleton(
    () => ConfigureAppGenerator(
      logger: sl(),
      infraSpecBundleReader: sl(),
      managedPackageDependencySync: sl(),
      diFileSyncService: sl(),
      appDependencyInstaller: sl(),
      report: sl(),
    ),
  );
  sl.registerLazySingleton(() => ComposeGenerator(logger: sl(), report: sl()));
}

/// Helper untuk mendaftarkan semua command ke CommandRunner
void registerCommands(CommandRunner runner) {
  runner
    ..addCommand(CreateCommand(workspaceGenerator: sl()))
    ..addCommand(
      ConfigureCommand(
        initGenerator: sl(),
        logger: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ConfigureAppCommand(configureAppGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(ListPckgCommand(logger: sl(), workspaceService: sl()))
    ..addCommand(GenAppCommand(appGenerator: sl(), workspaceService: sl()))
    ..addCommand(
      GenModuleCommand(
        moduleGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      GenFeatureCommand(
        featureGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      EnumCommand(
        enumGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      DtoCommand(dtoGenerator: sl(), workspaceService: sl(), operations: sl()),
    )
    ..addCommand(
      EntityCommand(
        entityGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ParamCommand(
        paramGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      RequestCommand(
        requestGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ParamRequestCommand(
        paramRequestGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      EntityDtoCommand(
        entityDtoGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      RegenFeatureCommand(featureGenerator: sl(), workspaceService: sl()),
    )
    // --- Slices Commands ---
    ..addCommand(
      SliceRCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceMCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceMpCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceMrCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceMrpCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceRofCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceRpCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceRpagCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceRsCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      SliceRspCommand(
        sliceGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    // --- Input Commands ---
    ..addCommand(InputTextCommand(inputGenerator: sl(), workspaceService: sl()))
    ..addCommand(
      InputTextAreaCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputNumberCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(InputQtyCommand(inputGenerator: sl(), workspaceService: sl()))
    ..addCommand(
      InputDropdownCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputDropdownEnumCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputPasswordCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputSelectorCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputSelectorListCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputImageCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      InputSwitchCommand(inputGenerator: sl(), workspaceService: sl()),
    )
    // --- UI Commands ---
    ..addCommand(
      UiMainCommand(
        uiGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      UiDialogCommand(
        uiGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      UiFormCommand(
        uiGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      UiFormDialogCommand(
        uiGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      UiLshCommand(uiGenerator: sl(), workspaceService: sl(), operations: sl()),
    )
    ..addCommand(
      UiLsvCommand(uiGenerator: sl(), workspaceService: sl(), operations: sl()),
    )
    ..addCommand(
      UiPagCommand(uiGenerator: sl(), workspaceService: sl(), operations: sl()),
    )
    ..addCommand(
      UiPmiCommand(uiGenerator: sl(), workspaceService: sl(), operations: sl()),
    )
    ..addCommand(
      UiActionCommand(
        uiGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      UiSecCommand(uiGenerator: sl(), workspaceService: sl(), operations: sl()),
    )
    // --- Maintenance & Compose Commands ---
    ..addCommand(RegCommand(workspaceService: sl(), regModuleGenerator: sl()))
    ..addCommand(DiCommand(diGenerator: sl(), workspaceService: sl()))
    ..addCommand(CpUiCommand(cpUiGenerator: sl(), workspaceService: sl()))
    ..addCommand(FixImportCommand(workspaceService: sl(), logger: sl()))
    ..addCommand(RebuildCommand(rebuildGenerator: sl(), workspaceService: sl()))
    ..addCommand(RefreshCommand(refreshGenerator: sl(), workspaceService: sl()))
    ..addCommand(
      ComposeMainCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposeFormCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposeFormDialogCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposeDialogCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposePagCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposePmiCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposeActionCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      ComposeSecCommand(
        composeGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    )
    ..addCommand(
      RmRegCommand(rmRegModuleGenerator: sl(), workspaceService: sl()),
    )
    ..addCommand(
      RmFeatureCommand(
        rmFeatureGenerator: sl(),
        workspaceService: sl(),
        operations: sl(),
      ),
    );
}
