import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fsda_cli/core/constants/cli_info.dart';
import 'package:fsda_cli/presentation/cli_logger.dart';
import 'package:fsda_cli/presentation/commands/command_registry.dart';
import 'package:fsda_cli/presentation/di/injection.dart';

void main(List<String> arguments) async {
  configureDependencies();
  final logger = sl<CliLogger>();

  final runner = CommandRunner<int>(CliInfo.name, CliInfo.description);
  registerCommands(runner);

  try {
    if (arguments.isNotEmpty) {
      final commandName = arguments.first;

      final registeredCommands = runner.commands.keys;
      if (!commandName.startsWith('-') &&
          !registeredCommands.contains(commandName)) {
        logger.error('Command "$commandName" is not recognized.');
        logger.log('Run "fsda --help" to see a list of available commands.');
        exitCode = 64;
        return;
      }
    }

    final parsedArgs = runner.argParser.parse(arguments);

    if (checkVersionFlag(parsedArgs, logger)) return;

    final result = await runner.run(arguments);

    if (result is int) {
      exitCode = result;
    }
  } on UsageException catch (e) {
    logger.error(e.message);
    logger.log('');
    logger.log(e.usage);
    exitCode = 64;
  } catch (e) {
    if (e is FormatException) {
      logger.error(e.message);
      logger.log('Run "fsda --help" for more information.');
    } else {
      logger.error('An unexpected error occurred: $e');
    }
    exitCode = 1;
  }
}
