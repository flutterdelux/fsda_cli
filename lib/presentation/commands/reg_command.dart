import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../resolvers/app_resolver.dart';
import '../resolvers/feature_resolver.dart';
import '../resolvers/module_resolver.dart';
import 'reg_feature_command.dart';
import 'reg_module_command.dart';
import 'wrapper/base_command.dart';

class RegCommand extends BaseCommand {
  final RegModuleCommand _regModuleCommand;
  final RegFeatureCommand _regFeatureCommand;

  @override
  final String name = 'reg';

  @override
  final String description = 'Register module or feature to an app.';

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  RegCommand({
    required RegModuleCommand regModuleCommand,
    required RegFeatureCommand regFeatureCommand,
  }) : _regModuleCommand = regModuleCommand,
       _regFeatureCommand = regFeatureCommand;

  @override
  Future<int> run() async {
    final args = argResults?.arguments ?? [];

    final hasApp = hasOption(AppResolverKeys.app, abbr: 'a');
    final hasModule = hasOption(ModuleResolverKeys.module, abbr: 'm');
    final hasFeature = hasOption(FeatureResolverKeys.feature, abbr: 'f');

    final String targetSubcommand;
    if (hasApp && hasModule && !hasFeature) {
      targetSubcommand = _regModuleCommand.name;
    } else if (hasApp && hasModule && hasFeature) {
      targetSubcommand = _regFeatureCommand.name;
    } else {
      usageException(
        'Use one of these combinations:\n'
        '  fsda reg -a <app> -m <module>\n'
        '  fsda reg -a <app> -m <module> -f <feature>',
      );
    }

    final internalRunner = CommandRunner<int>('fsda $name', description)
      ..addCommand(_regModuleCommand)
      ..addCommand(_regFeatureCommand);

    return await internalRunner.run([targetSubcommand, ...args]) ?? successCode;
  }
}
