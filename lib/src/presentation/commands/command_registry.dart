import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../../../di/injection.dart';
import '../../core/constants/cli_info.dart';
import '../cli_logger.dart';
import 'create_workspace_command.dart';

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

  runner.addCommand(
    CreateWorkspaceCommand(logger: sl(), workspaceService: sl()),
  );
}
