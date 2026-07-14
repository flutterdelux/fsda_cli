import 'package:args/command_runner.dart';

import '../constants/cli_rules.dart';
import '../generators/module_generator.dart';
import '../services/workspace_service.dart';

class GenModuleCommand extends Command<void> {
  final ModuleGenerator moduleGenerator;
  final WorkspaceService workspaceService;

  GenModuleCommand({
    required this.moduleGenerator,
    required this.workspaceService,
  });

  @override
  final String name = 'gen-module';

  @override
  final String description = 'Generate a module in workspace/modules/<module>.';

  @override
  String get invocation => 'fsda gen-module <module>';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing module name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final module = args.first;
    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module)) {
      throw UsageException(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
        usage,
      );
    }

    await moduleGenerator.generate((module: module));
  }
}
