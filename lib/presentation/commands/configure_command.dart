import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../resolvers/app_resolver.dart';
import 'configure_app_command.dart';
import 'wrapper/base_command.dart';

class ConfigureCommand extends BaseCommand {
  final ConfigureAppCommand _configureAppCommand;

  @override
  final String name = 'configure';

  @override
  final String description = 'Configure app, module (plan), or feature (plan).';

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  ConfigureCommand({required ConfigureAppCommand configureAppCommand})
    : _configureAppCommand = configureAppCommand;

  @override
  Future<int> run() async {
    final args = argResults?.arguments ?? [];

    final hasApp = hasOption(AppResolverKeys.app, abbr: 'a');

    final String targetSubcommand;
    if (hasApp) {
      targetSubcommand = _configureAppCommand.name;
    } else {
      usageException(
        'Use one of these combinations:\n'
        '  fsda configure -a <app>',
      );
    }

    final internalRunner = CommandRunner<int>('fsda $name', description)
      ..addCommand(_configureAppCommand);

    return await internalRunner.run([targetSubcommand, ...args]) ?? successCode;
  }
}
