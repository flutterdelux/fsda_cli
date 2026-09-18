import 'dart:io';

import 'package:path/path.dart' as p;

import 'base_generator.dart';

const _rebuildPostHooks = [
  'flutter clean',
  'flutter pub get',
  'flutter gen-l10n',
  'dart run build_runner build --delete-conflicting-outputs --force-jit',
];

class RebuildGenerator extends BaseGenerator<void, ({String module})> {
  const RebuildGenerator({required super.logger, required super.hookService});

  @override
  Future<void> generate(({String module}) args) async {
    final module = args.module;

    if (hookService == null) {
      logger.error('HookService is required for rebuild command.');
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
      'Running rebuild hooks for module "$module"...',
    );

    try {
      await hookService!.runHook(
        hooks: _rebuildPostHooks,
        workingDirectory: moduleRoot,
        logger: logger,
        operationLabel: 'fsda rebuild',
        timeout: const Duration(minutes: 15),
      );

      progress.complete('Rebuild hooks completed for module "$module".');
    } catch (e) {
      progress.fail('Failed to rebuild module "$module": $e');
      exitCode = 1;
    }
  }
}
