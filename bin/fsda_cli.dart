import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fsda_cli/commands/composition/compose_action_command.dart';
import 'package:fsda_cli/commands/composition/compose_dialog_command.dart';
import 'package:fsda_cli/commands/composition/compose_form_command.dart';
import 'package:fsda_cli/commands/composition/compose_form_dialog_command.dart';
import 'package:fsda_cli/commands/composition/compose_main_command.dart';
import 'package:fsda_cli/commands/composition/compose_pag_command.dart';
import 'package:fsda_cli/commands/composition/compose_pmi_command.dart';
import 'package:fsda_cli/commands/composition/compose_sec_command.dart';
import 'package:fsda_cli/commands/generation/dto_command.dart';
import 'package:fsda_cli/commands/generation/entity_command.dart';
import 'package:fsda_cli/commands/generation/enum_command.dart';
import 'package:fsda_cli/commands/generation/gen_app_command.dart';
import 'package:fsda_cli/commands/generation/gen_feature_command.dart';
import 'package:fsda_cli/commands/generation/gen_module_command.dart';
import 'package:fsda_cli/commands/generation/param_command.dart';
import 'package:fsda_cli/commands/generation/regen_feature_command.dart';
import 'package:fsda_cli/commands/generation/request_command.dart';
import 'package:fsda_cli/commands/generation/slice_m_command.dart';
import 'package:fsda_cli/commands/generation/slice_mp_command.dart';
import 'package:fsda_cli/commands/generation/slice_mr_command.dart';
import 'package:fsda_cli/commands/generation/slice_mrp_command.dart';
import 'package:fsda_cli/commands/generation/slice_r_command.dart';
import 'package:fsda_cli/commands/generation/slice_rof_command.dart';
import 'package:fsda_cli/commands/generation/slice_rp_command.dart';
import 'package:fsda_cli/commands/generation/slice_rpag_command.dart';
import 'package:fsda_cli/commands/generation/slice_rs_command.dart';
import 'package:fsda_cli/commands/generation/slice_rsp_command.dart';
import 'package:fsda_cli/commands/input/input_dropdown_command.dart';
import 'package:fsda_cli/commands/input/input_dropdown_enum_command.dart';
import 'package:fsda_cli/commands/input/input_image_command.dart';
import 'package:fsda_cli/commands/input/input_number_command.dart';
import 'package:fsda_cli/commands/input/input_password_command.dart';
import 'package:fsda_cli/commands/input/input_qty_command.dart';
import 'package:fsda_cli/commands/input/input_selector_command.dart';
import 'package:fsda_cli/commands/input/input_selector_list_command.dart';
import 'package:fsda_cli/commands/input/input_switch_command.dart';
import 'package:fsda_cli/commands/input/input_text_area_command.dart';
import 'package:fsda_cli/commands/input/input_text_command.dart';
import 'package:fsda_cli/commands/maintenance/cp_ui_command.dart';
import 'package:fsda_cli/commands/maintenance/di_command.dart';
import 'package:fsda_cli/commands/maintenance/fix_import_command.dart';
import 'package:fsda_cli/commands/maintenance/rebuild_command.dart';
import 'package:fsda_cli/commands/maintenance/refresh_command.dart';
import 'package:fsda_cli/commands/maintenance/reg_command.dart';
import 'package:fsda_cli/commands/maintenance/rm_feature_command.dart';
import 'package:fsda_cli/commands/maintenance/rm_reg_command.dart';
import 'package:fsda_cli/commands/ui/ui_action_command.dart';
import 'package:fsda_cli/commands/ui/ui_dialog_command.dart';
import 'package:fsda_cli/commands/ui/ui_form_command.dart';
import 'package:fsda_cli/commands/ui/ui_form_dialog_command.dart';
import 'package:fsda_cli/commands/ui/ui_lsh_command.dart';
import 'package:fsda_cli/commands/ui/ui_lsv_command.dart';
import 'package:fsda_cli/commands/ui/ui_main_command.dart';
import 'package:fsda_cli/commands/ui/ui_pag_command.dart';
import 'package:fsda_cli/commands/ui/ui_pmi_command.dart';
import 'package:fsda_cli/commands/ui/ui_sec_command.dart';
import 'package:fsda_cli/commands/workspace/add_pckg_command.dart';
import 'package:fsda_cli/commands/workspace/configure_app_command.dart';
import 'package:fsda_cli/commands/workspace/configure_command.dart';
import 'package:fsda_cli/commands/workspace/create_command.dart';
import 'package:fsda_cli/commands/workspace/list_pckg_command.dart';
import 'package:fsda_cli/constants/cli_info.dart';
import 'package:fsda_cli/generators/app_generator.dart';
import 'package:fsda_cli/generators/composition/compose_generator.dart';
import 'package:fsda_cli/generators/configure_app_generator.dart';
import 'package:fsda_cli/generators/configure_generator.dart';
import 'package:fsda_cli/generators/cp_ui_generator.dart';
import 'package:fsda_cli/generators/di_generator.dart';
import 'package:fsda_cli/generators/domain/dto_generator.dart';
import 'package:fsda_cli/generators/domain/entity_generator.dart';
import 'package:fsda_cli/generators/domain/param_generator.dart';
import 'package:fsda_cli/generators/domain/request_generator.dart';
import 'package:fsda_cli/generators/enum_generator.dart';
import 'package:fsda_cli/generators/feature_generator.dart';
import 'package:fsda_cli/generators/input/input_generator.dart';
import 'package:fsda_cli/generators/module_generator.dart';
import 'package:fsda_cli/generators/package_generator.dart';
import 'package:fsda_cli/generators/rebuild_generator.dart';
import 'package:fsda_cli/generators/refresh_generator.dart';
import 'package:fsda_cli/generators/reg_module_generator.dart';
import 'package:fsda_cli/generators/rm_feature_generator.dart';
import 'package:fsda_cli/generators/rm_reg_module_generator.dart';
import 'package:fsda_cli/generators/slice_generator.dart';
import 'package:fsda_cli/generators/ui_generator.dart';
import 'package:fsda_cli/generators/workspace_generator.dart';
import 'package:fsda_cli/services/bundle_service.dart';
import 'package:fsda_cli/services/file_service.dart';
import 'package:fsda_cli/services/hook_service.dart';
import 'package:fsda_cli/services/logger_service.dart';
import 'package:fsda_cli/services/process_service.dart';
import 'package:fsda_cli/services/pubspec_service.dart';
import 'package:fsda_cli/services/sdk_service.dart';
import 'package:fsda_cli/services/workspace_service.dart';

void main(List<String> arguments) async {
  // Initialize services
  final sdkService = SdkService();
  final logger = LoggerService();
  final processService = ProcessService();
  final pubspecService = PubspecService(processService: processService);
  final fileService = FileService(sdkService: sdkService);
  final hookService = HookService(processService: processService);
  final bundleService = BundleService(fileService: fileService);
  final workspaceService = WorkspaceService();

  // Initialize generators
  final workspaceGenerator = WorkspaceGenerator(logger: logger);

  final packageGenerator = PackageGenerator(
    logger: logger,
    pubspecService: pubspecService,
    fileService: fileService,
    hookService: hookService,
    processService: processService,
    bundleService: bundleService,
  );
  final initGenerator = ConfigureGenerator(
    logger: logger,
    packageGenerator: packageGenerator,
  );
  final appGenerator = AppGenerator(
    logger: logger,
    pubspecService: pubspecService,
    fileService: fileService,
    hookService: hookService,
    processService: processService,
    sdkService: sdkService,
  );
  final moduleGenerator = ModuleGenerator(
    logger: logger,
    fileService: fileService,
    sdkService: sdkService,
    pubspecService: pubspecService,
    hookService: hookService,
  );
  final featureGenerator = FeatureGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final enumGenerator = EnumGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final dtoGenerator = DtoGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final entityGenerator = EntityGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final paramGenerator = ParamGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final requestGenerator = RequestGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final sliceGenerator = SliceGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final inputGenerator = InputGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final uiGenerator = UiGenerator(
    logger: logger,
    fileService: fileService,
    hookService: hookService,
  );
  final regModuleGenerator = RegModuleGenerator(
    logger: logger,
    fileService: fileService,
  );
  final rmRegModuleGenerator = RmRegModuleGenerator(
    logger: logger,
    fileService: fileService,
  );
  final rmFeatureGenerator = RmFeatureGenerator(
    logger: logger,
    hookService: hookService,
  );
  final cpUiGenerator = CpUiGenerator(logger: logger);
  final rebuildGenerator = RebuildGenerator(
    logger: logger,
    hookService: hookService,
  );
  final refreshGenerator = RefreshGenerator(
    logger: logger,
    hookService: hookService,
  );
  final diGenerator = DiGenerator(logger: logger);
  final configureAppGenerator = ConfigureAppGenerator(
    logger: logger,
    processService: processService,
  );
  final composeGenerator = ComposeGenerator(logger: logger);

  // Initialize command runner
  final runner = CommandRunner('fsda', 'Feature Slice Driven Architecture CLI')
    ..addCommand(CreateCommand(workspaceGenerator: workspaceGenerator))
    ..addCommand(
      ConfigureCommand(
        initGenerator: initGenerator,
        logger: logger,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ConfigureAppCommand(
        configureAppGenerator: configureAppGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ListPckgCommand(logger: logger, workspaceService: workspaceService),
    )
    ..addCommand(
      AddPckgCommand(
        packageGenerator: packageGenerator,
        logger: logger,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      GenAppCommand(
        appGenerator: appGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      GenModuleCommand(
        moduleGenerator: moduleGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      GenFeatureCommand(
        featureGenerator: featureGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      EnumCommand(
        enumGenerator: enumGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      DtoCommand(
        dtoGenerator: dtoGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      EntityCommand(
        entityGenerator: entityGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ParamCommand(
        paramGenerator: paramGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      RequestCommand(
        requestGenerator: requestGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      RegenFeatureCommand(
        featureGenerator: featureGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceRCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceMCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceMpCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceMrCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceMrpCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceRofCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceRpCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceRpagCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceRsCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      SliceRspCommand(
        sliceGenerator: sliceGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputTextCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputTextAreaCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputNumberCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputQtyCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputDropdownCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputDropdownEnumCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputPasswordCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputSelectorCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputSelectorListCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputImageCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      InputSwitchCommand(
        inputGenerator: inputGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiMainCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiDialogCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiFormCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiFormDialogCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiLshCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiLsvCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiPagCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiPmiCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiActionCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      UiSecCommand(
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      RegCommand(
        workspaceService: workspaceService,
        regModuleGenerator: regModuleGenerator,
      ),
    )
    ..addCommand(
      DiCommand(diGenerator: diGenerator, workspaceService: workspaceService),
    )
    ..addCommand(
      CpUiCommand(
        cpUiGenerator: cpUiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      FixImportCommand(workspaceService: workspaceService, logger: logger),
    )
    ..addCommand(
      RebuildCommand(
        rebuildGenerator: rebuildGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      RefreshCommand(
        refreshGenerator: refreshGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposeMainCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposeFormCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposeFormDialogCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposeDialogCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposePagCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposePmiCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposeActionCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      ComposeSecCommand(
        composeGenerator: composeGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      RmRegCommand(
        rmRegModuleGenerator: rmRegModuleGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      RmFeatureCommand(
        rmFeatureGenerator: rmFeatureGenerator,
        workspaceService: workspaceService,
      ),
    );

  runner.argParser.addFlag(
    'version',
    negatable: false,
    help: 'Print the tool version.',
  );

  try {
    final parsedArgs = runner.argParser.parse(arguments);
    if (parsedArgs.flag('version')) {
      logger.log('fsda version: ${CliInfo.version}');
      return;
    }

    await runner.run(arguments);
  } on UsageException catch (e) {
    logger.error(e.message);
    logger.log('');
    logger.log(e.usage);
    exitCode = 64;
  } catch (e) {
    logger.error('An unexpected error occurred: $e');
    exitCode = 1;
  }
}
