import 'dart:io';

import 'package:path/path.dart' as p;

import '../services/hook_service.dart';
import '../services/logger_service.dart';

const _rebuildPostHooks = [
  'flutter clean',
  'flutter pub get',
  'flutter gen-l10n',
  'dart run build_runner build --delete-conflicting-outputs --force-jit',
];

class RebuildGenerator {
  final LoggerService logger;
  final HookService hookService;

  const RebuildGenerator({required this.logger, required this.hookService});

  Future<void> generate(({String module}) args) async {
    final module = args.module;

    final moduleRoot = p.join(Directory.current.path, 'modules', module);
    final moduleDir = Directory(moduleRoot);
    if (!await moduleDir.exists()) {
      logger.error('Module "$module" does not exist.');
      exitCode = 1;
      return;
    }

    final progress = logger.progress(
      'Running rebuild hooks for module "$module"...',
    );

    try {
      await hookService.runHook(
        hooks: _rebuildPostHooks,
        workingDirectory: moduleRoot,
        logger: logger,
        operationLabel: 'fsda rebuild $module',
        timeout: const Duration(minutes: 15),
      );

      progress.complete('Rebuild hooks completed for module "$module".');
    } catch (e) {
      progress.fail('Failed to rebuild module "$module": $e');
      exitCode = 1;
    }
  }
}
