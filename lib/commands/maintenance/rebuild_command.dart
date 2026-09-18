import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/rebuild_generator.dart';
import '../../services/workspace_service.dart';

class RebuildCommand extends Command<void> {
  final RebuildGenerator rebuildGenerator;
  final WorkspaceService workspaceService;

  RebuildCommand({
    required this.rebuildGenerator,
    required this.workspaceService,
  });

  @override
  final String name = 'rebuild';

  @override
  final String description =
      'Run full module rebuild pipeline (clean, pub get, gen-l10n, build_runner).';

  @override
  String get invocation => 'fsda rebuild <module>';

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
        'Invalid module name "$module".\n${CliRules.moduleNameRule}',
        usage,
      );
    }

    final moduleDir = Directory(
      p.join(Directory.current.path, 'modules', module),
    );
    if (!await moduleDir.exists()) {
      throw UsageException('Module "$module" does not exist.', usage);
    }

    await rebuildGenerator.generate((module: module));
  }
}
