import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fsda_cli/commands/add_pckg_command.dart';
import 'package:fsda_cli/commands/compose_form_command.dart';
import 'package:fsda_cli/commands/compose_main_command.dart';
import 'package:fsda_cli/commands/compose_pag_command.dart';
import 'package:fsda_cli/commands/compose_pmi_command.dart';
import 'package:fsda_cli/commands/compose_sec_command.dart';
import 'package:fsda_cli/commands/configure_app_command.dart';
import 'package:fsda_cli/commands/configure_command.dart';
import 'package:fsda_cli/commands/create_command.dart';
import 'package:fsda_cli/commands/di_command.dart';
import 'package:fsda_cli/commands/fix_import_command.dart';
import 'package:fsda_cli/commands/gen_app_command.dart';
import 'package:fsda_cli/commands/gen_feature_command.dart';
import 'package:fsda_cli/commands/gen_module_command.dart';
import 'package:fsda_cli/commands/gen_slice_command.dart';
import 'package:fsda_cli/commands/gen_ui_command.dart';
import 'package:fsda_cli/commands/list_pckg_command.dart';
import 'package:fsda_cli/commands/reg_command.dart';
import 'package:fsda_cli/commands/regen_feature_command.dart';
import 'package:fsda_cli/commands/rm_reg_command.dart';
import 'package:fsda_cli/constants/cli_info.dart';
import 'package:fsda_cli/generators/app_generator.dart';
import 'package:fsda_cli/generators/compose_generator.dart';
import 'package:fsda_cli/generators/configure_app_generator.dart';
import 'package:fsda_cli/generators/configure_generator.dart';
import 'package:fsda_cli/generators/di_generator.dart';
import 'package:fsda_cli/generators/feature_generator.dart';
import 'package:fsda_cli/generators/module_generator.dart';
import 'package:fsda_cli/generators/package_generator.dart';
import 'package:fsda_cli/generators/reg_module_generator.dart';
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
  final sliceGenerator = SliceGenerator(
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
      RegenFeatureCommand(
        featureGenerator: featureGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      GenSliceCommand(
        sliceGenerator: sliceGenerator,
        uiGenerator: uiGenerator,
        workspaceService: workspaceService,
      ),
    )
    ..addCommand(
      GenUiCommand(
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
      FixImportCommand(workspaceService: workspaceService, logger: logger),
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
