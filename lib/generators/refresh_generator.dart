import 'dart:io';

import 'package:path/path.dart' as p;

import 'base_generator.dart';

const _refreshPostHooks = [
  'flutter gen-l10n',
  'dart run build_runner build --delete-conflicting-outputs --force-jit',
];

class RefreshGenerator extends BaseGenerator<void, ({String module})> {
  const RefreshGenerator({required super.logger, required super.hookService});

  @override
  Future<void> generate(({String module}) args) async {
    final module = args.module;

    if (hookService == null) {
      logger.error('HookService is required for refresh command.');
      exitCode = 1;
      return;
    }

    final moduleRoot = p.join(Directory.current.path, 'modules', module);
    final moduleDir = Directory(moduleRoot);
    if (!await moduleDir.exists()) {
      logger.error('Module "$module" does not exist.');
      exitCode = 1;
      return;
    }

    final progress = logger.progress(
      'Running refresh hooks for module "$module"...',
    );

    try {
      await hookService!.runHook(
        hooks: _refreshPostHooks,
        workingDirectory: moduleRoot,
        logger: logger,
        operationLabel: 'fsda refresh',
        timeout: const Duration(minutes: 10),
      );

      progress.complete('Refresh hooks completed for module "$module".');
    } catch (e) {
      progress.fail('Failed to refresh module "$module": $e');
      exitCode = 1;
    }
  }
}
