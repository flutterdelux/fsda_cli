import 'dart:io';

import 'package:path/path.dart' as p;

import '../services/hook_service.dart';
import '../services/logger_service.dart';

const _refreshPostHooks = [
  'flutter gen-l10n',
  'dart run build_runner build --delete-conflicting-outputs --force-jit',
];

class RefreshGenerator {
  final LoggerService logger;
  final HookService hookService;

  const RefreshGenerator({required this.logger, required this.hookService});

  Future<void> generate(({String module}) args) async {
    final module = args.module;

    final moduleRoot = p.join(Directory.current.path, 'modules', module);
    final moduleDir = Directory(moduleRoot);
    if (!await moduleDir.exists()) {
      logger.error('Module "$module" does not exist.');
      exitCode = 1;
      return;
    }

    logger.info('Running refresh for module "$module"...');

    try {
      await hookService.runHook(
        hooks: _refreshPostHooks,
        workingDirectory: moduleRoot,
        logger: logger,
        operationLabel: 'fsda refresh $module',
        timeout: const Duration(minutes: 10),
      );

      logger.success('Refresh completed for module "$module".');
    } catch (e) {
      logger.error('Failed to refresh module "$module": $e');
      exitCode = 1;
    }
  }
}
