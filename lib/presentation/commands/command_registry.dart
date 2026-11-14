import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../../core/constants/cli_info.dart';
import '../cli_logger.dart';
import '../di/injection.dart';
import 'compose/compose_form_command.dart';
import 'compose/compose_mutation_command.dart';
import 'compose/compose_pagination_command.dart';
import 'compose/compose_retrieval_command.dart';
import 'configure_app_command.dart';
import 'create_workspace_command.dart';
import 'ds_local_command.dart';
import 'ds_remote_command.dart';
import 'gen_app_command.dart';
import 'gen_enum_command.dart';
import 'gen_failure_command.dart';
import 'gen_feature_command.dart';
import 'gen_logic_command.dart';
import 'gen_logic_flow_command.dart';
import 'gen_model_command.dart';
import 'gen_module_command.dart';
import 'gen_sequence_command.dart';
import 'input/input_dropdown_command.dart';
import 'input/input_dropdown_enum_command.dart';
import 'input/input_image_command.dart';
import 'input/input_number_command.dart';
import 'input/input_password_command.dart';
import 'input/input_qty_command.dart';
import 'input/input_selector_command.dart';
import 'input/input_switch_command.dart';
import 'input/input_text_area_command.dart';
import 'input/input_text_command.dart';
import 'maintenance/drb_command.dart';
import 'maintenance/fix_import_command.dart';
import 'maintenance/l10n_command.dart';
import 'maintenance/rebuild_command.dart';
import 'maintenance/refresh_command.dart';
import 'package/pkg_command.dart';
import 'reg_feature_command.dart';
import 'reg_module_command.dart';
import 'rm_enum_command.dart';
import 'rm_feature_command.dart';
import 'rm_model_command.dart';
import 'rm_sequence_command.dart';
import 'ui/gen_ui_command.dart';
import 'ui/gen_ui_form_command.dart';
import 'ui/gen_ui_lsh_command.dart';
import 'ui/gen_ui_lsv_command.dart';
import 'ui/gen_ui_pag_command.dart';

bool checkVersionFlag(ArgResults parsedArgs, CliLogger logger) {
  if (parsedArgs.flag('version')) {
    logger.log('${CliInfo.name} version: ${CliInfo.version}');
    return true; // Indicates that the version has been processed
  }
  return false;
}

void registerCommands(CommandRunner runner) {
  runner.argParser.addFlag(
    'version',
    negatable: false,
    help: 'Print the tool version.',
  );

  // Workspace
  runner.addCommand(
    CreateWorkspaceCommand(
      logger: sl(),
      workspaceService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );

  // Package
  runner.addCommand(
    PkgCommand(
      logger: sl(),
      configService: sl(),
      packageSyncService: sl(),
      reportService: sl(),
      directoryService: sl(),
    ),
  );

  // App
  runner.addCommand(
    GenAppCommand(
      configService: sl(),
      logger: sl(),
      appService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    ConfigureAppCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      configureAppService: sl(),
    ),
  );

  // Module
  runner.addCommand(
    GenModuleCommand(
      moduleService: sl(),
      logger: sl(),
      configService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    GenFailureCommand(
      logger: sl(),
      configService: sl(),
      directoryService: sl(),
      reportService: sl(),
      failureService: sl(),
      fileService: sl(),
    ),
  );

  // Feature
  runner.addCommand(
    GenFeatureCommand(
      configService: sl(),
      logger: sl(),
      featureService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    RmFeatureCommand(
      configService: sl(),
      logger: sl(),
      featureService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );

  // Data Source
  runner.addCommand(
    DsRemoteCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      fileService: sl(),
      reportService: sl(),
      dataSourceService: sl(),
    ),
  );
  runner.addCommand(
    DsLocalCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      fileService: sl(),
      reportService: sl(),
      dataSourceService: sl(),
    ),
  );

  // Enum
  runner.addCommand(
    GenEnumCommand(
      configService: sl(),
      logger: sl(),
      enumService: sl(),
      directoryService: sl(),
      fileService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    RmEnumCommand(
      configService: sl(),
      logger: sl(),
      enumService: sl(),
      directoryService: sl(),
      fileService: sl(),
      reportService: sl(),
    ),
  );

  // Model
  runner.addCommand(
    GenModelCommand(
      configService: sl(),
      logger: sl(),
      modelService: sl(),
      directoryService: sl(),
      fileService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    RmModelCommand(
      configService: sl(),
      logger: sl(),
      modelService: sl(),
      directoryService: sl(),
      fileService: sl(),
      reportService: sl(),
    ),
  );

  // Sequence
  runner.addCommand(
    GenSequenceCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      sequenceService: sl(),
      fileService: sl(),
      methodService: sl(),
    ),
  );
  runner.addCommand(
    RmSequenceCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      sequenceService: sl(),
      fileService: sl(),
    ),
  );

  // Logic
  runner.addCommand(
    GenLogicCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      logicService: sl(),
    ),
  );
  runner.addCommand(
    GenLogicFlowCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      logicService: sl(),
      logicUcService: sl(),
    ),
  );

  // Maintenance
  runner.addCommand(
    DrbCommand(
      configService: sl(),
      logger: sl(),
      buildRunnerService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    L10nCommand(
      configService: sl(),
      logger: sl(),
      l10nService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    RebuildCommand(
      configService: sl(),
      logger: sl(),
      rebuildService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    RefreshCommand(
      configService: sl(),
      logger: sl(),
      refreshService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );
  runner.addCommand(
    FixImportCommand(
      configService: sl(),
      logger: sl(),
      fixImportService: sl(),
      directoryService: sl(),
      reportService: sl(),
    ),
  );

  // Input
  runner.addCommand(
    InputDropdownCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputDropdownEnumCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputImageCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputNumberCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputPasswordCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputQtyCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputSelectorCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputSwitchCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputTextAreaCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );
  runner.addCommand(
    InputTextCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      inputService: sl(),
    ),
  );

  // UI
  runner.addCommand(
    GenUICommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      uiService: sl(),
    ),
  );
  runner.addCommand(
    GenUIFormCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      uiService: sl(),
    ),
  );
  runner.addCommand(
    GenUILshCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      uiService: sl(),
    ),
  );
  runner.addCommand(
    GenUILsvCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      uiService: sl(),
    ),
  );
  runner.addCommand(
    GenUIPagCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      uiService: sl(),
    ),
  );

  runner.addCommand(
    RegModuleCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      regModuleService: sl(),
    ),
  );
  runner.addCommand(
    RegFeatureCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      fileService: sl(),
      regFeatureService: sl(),
    ),
  );

  // Compose
  runner.addCommand(
    ComposePaginationCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      composeService: sl(),
      fileService: sl(),
    ),
  );
  runner.addCommand(
    ComposeRetrievalCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      composeService: sl(),
      fileService: sl(),
    ),
  );
  runner.addCommand(
    ComposeFormCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      composeService: sl(),
      fileService: sl(),
    ),
  );
  runner.addCommand(
    ComposeMutationCommand(
      configService: sl(),
      logger: sl(),
      directoryService: sl(),
      reportService: sl(),
      composeService: sl(),
      fileService: sl(),
    ),
  );
}
