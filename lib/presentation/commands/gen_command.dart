import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../resolvers/app_resolver.dart';
import '../resolvers/failure_resolver.dart';
import '../resolvers/feature_resolver.dart';
import '../resolvers/module_resolver.dart';
import 'gen_app_command.dart';
import 'gen_failure_command.dart';
import 'gen_feature_command.dart';
import 'gen_module_command.dart';
import 'wrapper/base_command.dart';

class GenCommand extends BaseCommand {
  final GenAppCommand _genAppCommand;
  final GenModuleCommand _genModuleCommand;
  final GenFeatureCommand _genFeatureCommand;
  final GenFailureCommand _genFailureCommand;

  @override
  final String name = 'gen';

  @override
  final String description = 'Generate app, module, feature, or failure.';

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  GenCommand({
    required GenAppCommand genAppCommand,
    required GenModuleCommand genModuleCommand,
    required GenFeatureCommand genFeatureCommand,
    required GenFailureCommand genFailureCommand,
  }) : _genAppCommand = genAppCommand,
       _genModuleCommand = genModuleCommand,
       _genFeatureCommand = genFeatureCommand,
       _genFailureCommand = genFailureCommand;

  @override
  Future<int> run() async {
    final args = argResults?.arguments ?? [];

    final hasApp = hasOption(AppResolverKeys.app, abbr: 'a');
    final hasModule = hasOption(ModuleResolverKeys.module, abbr: 'm');
    final hasFeature = hasOption(FeatureResolverKeys.feature, abbr: 'f');
    final hasFailure = hasOption(FailureResolverKeys.failure);

    final String targetSubcommand;
    if (hasApp && !hasModule && !hasFeature && !hasFailure) {
      targetSubcommand = _genAppCommand.name;
    } else if (hasModule && !hasApp && !hasFeature && !hasFailure) {
      targetSubcommand = _genModuleCommand.name;
    } else if (hasModule && hasFeature && !hasApp && !hasFailure) {
      targetSubcommand = _genFeatureCommand.name;
    } else if (hasModule && hasFailure && !hasApp && !hasFeature) {
      targetSubcommand = _genFailureCommand.name;
    } else {
      usageException(
        'Use one of these combinations:\n'
        '  fsda gen -a <app>\n'
        '  fsda gen -m <module>\n'
        '  fsda gen -m <module> -f <feature>\n'
        '  fsda gen -m <module> --failure "<name>:<message>"',
      );
    }

    final internalRunner = CommandRunner<int>('fsda $name', description)
      ..addCommand(_genAppCommand)
      ..addCommand(_genModuleCommand)
      ..addCommand(_genFeatureCommand)
      ..addCommand(_genFailureCommand);

    return await internalRunner.run([targetSubcommand, ...args]) ?? successCode;
  }
}
