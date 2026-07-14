import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../services/logger_service.dart';
import '../services/workspace_service.dart';

class FixImportCommand extends Command<void> {
  final WorkspaceService workspaceService;
  final LoggerService logger;

  FixImportCommand({required this.workspaceService, required this.logger}) {
    argParser
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption('app', abbr: 'a', help: 'Target app name.');
  }

  @override
  final String name = 'fix-import';

  @override
  final String description =
      'Auto-fix import ordering and remove unused imports using dart fix.';

  @override
  String get invocation => 'fsda fix-import [-m <module>] [-a <app>]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isNotEmpty) {
      throw UsageException(
        'Unexpected argument(s): "${args.join(' ')}". This command only accepts options.',
        usage,
      );
    }

    final module = (argResults?['module'] as String?)?.trim();
    final app = (argResults?['app'] as String?)?.trim();

    if ((module == null || module.isEmpty) && (app == null || app.isEmpty)) {
      throw UsageException(
        'At least one target is required: --module (-m) or --app (-a).',
        usage,
      );
    }

    final targets = <({String label, String path})>[];

    if (module != null && module.isNotEmpty) {
      final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
      if (!moduleNameRegExp.hasMatch(module)) {
        throw UsageException(
          'Invalid module name "$module".\n${CliRules.moduleNameRule}',
          usage,
        );
      }

      final modulePath = p.join(Directory.current.path, 'modules', module);
      if (!Directory(modulePath).existsSync()) {
        throw UsageException('Module "$module" does not exist.', usage);
      }

      targets.add((label: 'module/$module', path: modulePath));
    }

    if (app != null && app.isNotEmpty) {
      final appNameRegExp = RegExp(CliRules.appNamePattern);
      if (!appNameRegExp.hasMatch(app)) {
        throw UsageException(
          'Invalid app name "$app".\n${CliRules.appNameRule}',
          usage,
        );
      }

      final appPath = p.join(Directory.current.path, 'apps', app);
      if (!Directory(appPath).existsSync()) {
        throw UsageException('App "$app" does not exist.', usage);
      }

      targets.add((label: 'app/$app', path: appPath));
    }

    for (final target in targets) {
      logger.info('Applying import fixes for ${target.label}...');
      final result = await Process.run(
        'dart',
        const [
          'fix',
          '--apply',
          '--code=directives_ordering',
          '--code=unused_import',
        ],
        workingDirectory: target.path,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        final error = (result.stderr ?? '').toString().trim();
        throw Exception(
          error.isEmpty
              ? 'Failed to apply import fixes for ${target.label}.'
              : 'Failed to apply import fixes for ${target.label}: $error',
        );
      }

      logger.success('Import fixes applied for ${target.label}.');
    }

    logger.success('fix-import completed for ${targets.length} target(s).');
  }
}
