import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/refresh_generator.dart';
import '../../services/workspace_service.dart';

class RefreshCommand extends Command<void> {
  final RefreshGenerator refreshGenerator;
  final WorkspaceService workspaceService;

  RefreshCommand({
    required this.refreshGenerator,
    required this.workspaceService,
  });

  @override
  final String name = 'refresh';

  @override
  final String description =
      'Run module codegen refresh hooks (flutter gen-l10n + build_runner).';

  @override
  String get invocation => 'fsda refresh <module>';

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

    await refreshGenerator.generate((module: module));
  }
}
