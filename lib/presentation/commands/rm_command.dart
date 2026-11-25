import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../resolvers/feature_resolver.dart';
import '../resolvers/module_resolver.dart';
import 'rm_feature_command.dart';
import 'wrapper/base_command.dart';

class RmCommand extends BaseCommand {
  final RmFeatureCommand _rmFeatureCommand;

  @override
  final String name = 'rm';

  @override
  final String description = 'Remove feature.';

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  RmCommand({required RmFeatureCommand rmFeatureCommand})
    : _rmFeatureCommand = rmFeatureCommand;

  @override
  Future<int> run() async {
    final args = argResults?.arguments ?? [];

    final hasModule = hasOption(ModuleResolverKeys.module, abbr: 'm');
    final hasFeature = hasOption(FeatureResolverKeys.feature, abbr: 'f');

    final String targetSubcommand;
    if (hasModule && hasFeature) {
      targetSubcommand = _rmFeatureCommand.name;
    } else {
      usageException(
        'Use this combination:\n'
        '  fsda rm -m <module> -f <feature>',
      );
    }

    final internalRunner = CommandRunner<int>('fsda $name', description)
      ..addCommand(_rmFeatureCommand);

    return await internalRunner.run([targetSubcommand, ...args]) ?? successCode;
  }
}
