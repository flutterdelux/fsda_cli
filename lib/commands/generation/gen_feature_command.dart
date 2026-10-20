import 'package:args/command_runner.dart';

import '../../constants/cli_rules.dart';
import '../../enums/data_source_mode.dart';
import '../../generators/feature_generator.dart';
import '../../services/command_operation_service.dart';
import '../../services/workspace_service.dart';

class GenFeatureCommand extends Command<void> {
  final FeatureGenerator featureGenerator;
  final WorkspaceService workspaceService;
  final CommandOperationService operations;

  GenFeatureCommand({
    required this.featureGenerator,
    required this.workspaceService,
    required this.operations,
  }) {
    final datasourceHelp =
        'Datasource scaffold mode. Supported: ${DataSourceMode.values.map((mode) => mode.value).join(', ')}';

    argParser
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption(
        'datasource',
        aliases: ['ds'],
        defaultsTo: DataSourceMode.both.value,
        help: datasourceHelp,
      )
      ..addOption(
        'base-path',
        help:
            'Base route path for the generated remote data source (default: /<feature>s).',
      )
      ..addFlag(
        'hook-disabled',
        negatable: false,
        help:
            'Skip post-hook execution and print manual next steps to run afterward.',
      );
  }

  @override
  final String name = 'gen-feature';

  @override
  final String description =
      'Generate a feature in workspace/modules/<module>/lib/src/features/<feature>.';

  @override
  String get invocation =>
      'fsda gen-feature <feature> -m <module> [--ds <datasource_mode>|--datasource <datasource_mode>] [--base-path <base-path>] [--hook-disabled]';

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
    final datasource =
        (argResults?['datasource'] as String?)?.trim() ??
        DataSourceMode.both.value;
    final basePath = (argResults?['base-path'] as String?)?.trim();
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;
    if (module == null || module.isEmpty) {
      throw UsageException('Missing required option: --module (-m).', usage);
    }

    DataSourceMode dataSourceMode;
    try {
      dataSourceMode = DataSourceMode.fromValue(datasource);
    } catch (e) {
      throw UsageException(e.toString(), usage);
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature)) {
      throw UsageException(
        'Invalid feature name "$feature".\n'
        '${CliRules.featureNameRule}',
        usage,
      );
    }
    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module)) {
      throw UsageException(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
        usage,
      );
    }

    await operations.run<Map<String, dynamic>?>(
      operationLabel: 'fsda gen-feature $feature',
      hookDisabled: hookDisabled,
      action: () => featureGenerator.generate((
        feature: feature,
        module: module,
        dataSourceMode: dataSourceMode,
        basePath: basePath == null || basePath.isEmpty
            ? '/${feature.replaceAll('_', '-')}s'
            : basePath,
      )),
      hookResults: (result) => result == null ? const [] : [result],
    );
  }
}
