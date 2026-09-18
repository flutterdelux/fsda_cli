import 'package:args/command_runner.dart';

import '../../constants/cli_rules.dart';
import '../../generators/cp_ui_generator.dart';
import '../../services/workspace_service.dart';

class CpUiCommand extends Command<void> {
  final CpUiGenerator cpUiGenerator;
  final WorkspaceService workspaceService;

  CpUiCommand({required this.cpUiGenerator, required this.workspaceService}) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption(
        'from',
        help: 'Source UI slice name to copy from (snake_case).',
      );
  }

  @override
  final String name = 'cp-ui';

  @override
  final String description =
      'Copy and refactor UI slice into a new slice name (without copying logic/domain/data).';

  @override
  String get invocation =>
      'fsda cp-ui <new_slice> -f <feature> -m <module> --from <from_slice>';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing new slice name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final newSlice = args.first.trim();
    final feature = (argResults?['feature'] as String?)?.trim();
    final module = (argResults?['module'] as String?)?.trim();
    final fromSlice = (argResults?['from'] as String?)?.trim();

    final missingOptions = <String>[];
    if (feature == null || feature.isEmpty) missingOptions.add('--feature');
    if (module == null || module.isEmpty) missingOptions.add('--module');
    if (fromSlice == null || fromSlice.isEmpty) missingOptions.add('--from');
    if (missingOptions.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missingOptions.join(', ')}',
        usage,
      );
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature!)) {
      throw UsageException(
        'Invalid feature name "$feature".\n${CliRules.featureNameRule}',
        usage,
      );
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module!)) {
      throw UsageException(
        'Invalid module name "$module".\n${CliRules.moduleNameRule}',
        usage,
      );
    }

    final sliceNameRegExp = RegExp(CliRules.sliceNamePattern);
    if (!sliceNameRegExp.hasMatch(newSlice)) {
      throw UsageException(
        'Invalid new slice name "$newSlice".\n${CliRules.sliceNameRule}',
        usage,
      );
    }

    if (!sliceNameRegExp.hasMatch(fromSlice!)) {
      throw UsageException(
        'Invalid source slice name "$fromSlice".\n${CliRules.sliceNameRule}',
        usage,
      );
    }

    if (newSlice == fromSlice) {
      throw UsageException(
        'New slice and source slice cannot be the same value.',
        usage,
      );
    }

    await cpUiGenerator.generate((
      module: module,
      feature: feature,
      fromSlice: fromSlice,
      newSlice: newSlice,
    ));
  }
}
