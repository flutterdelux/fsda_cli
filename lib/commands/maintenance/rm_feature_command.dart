import 'package:args/command_runner.dart';

import '../../constants/cli_rules.dart';
import '../../generators/rm_feature_generator.dart';
import '../../services/workspace_service.dart';

class RmFeatureCommand extends Command<void> {
  final RmFeatureGenerator rmFeatureGenerator;
  final WorkspaceService workspaceService;

  RmFeatureCommand({
    required this.rmFeatureGenerator,
    required this.workspaceService,
  }) {
    argParser
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addFlag(
        'hook-disabled',
        negatable: false,
        help:
            'Skip post-hook execution and print manual next steps to run afterward.',
      );
  }

  @override
  final String name = 'rm-feature';

  @override
  final String description =
      'Remove feature directory, rollback feature-prefixed shared error + l10n injections, and run post-hooks for the module.';

  @override
  String get invocation =>
      'fsda rm-feature <feature> -m <module> [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing feature name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final feature = args.first;
    final module = argResults?['module'] as String?;
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;

    if (module == null || module.isEmpty) {
      throw UsageException('Missing required option: --module (-m).', usage);
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature)) {
      throw UsageException(
        'Invalid feature name "$feature".\n${CliRules.featureNameRule}',
        usage,
      );
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module)) {
      throw UsageException(
        'Invalid module name "$module".\n${CliRules.moduleNameRule}',
        usage,
      );
    }

    await rmFeatureGenerator.generate((
      module: module,
      feature: feature,
      hookDisabled: hookDisabled,
    ));
  }
}
