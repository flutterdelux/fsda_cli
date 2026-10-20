import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fsda_cli/src/core/constants/cli_info.dart';
import 'package:fsda_cli/src/presentation/cli_logger.dart';
import 'package:fsda_cli/src/presentation/commands/command_registry.dart';
import 'package:fsda_cli/src/presentation/di/injection.dart';

void main(List<String> arguments) async {
  configureDependencies();
  final logger = sl<CliLogger>();

  final runner = CommandRunner(CliInfo.name, CliInfo.description);
  registerCommands(runner);

  try {
    final parsedArgs = runner.argParser.parse(arguments);

    if (checkVersionFlag(parsedArgs, logger)) return;

    await runner.run(arguments);
  } on UsageException catch (e) {
    logger.error(e.message);
    logger.log('');
    logger.log(e.usage);
    exitCode = 64;
  } catch (e) {
    // logger.error('An unexpected error occurred: $e');
    exitCode = 1;
  }
}
