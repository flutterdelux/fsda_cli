import 'dart:io';

import '../services/file_service.dart';
import '../services/hook_service.dart';
import '../services/logger_service.dart';
import '../services/pubspec_service.dart';

abstract class BaseGenerator<R, Targs> {
  final LoggerService logger;
  final FileService? fileService;
  final PubspecService? pubspecService;
  final HookService? hookService;

  const BaseGenerator({
    required this.logger,
    this.fileService,
    this.pubspecService,
    this.hookService,
  });

  Future<R> generate(Targs args);

  Future<bool> generateTemplatePipeline({
    required String name,
    required Directory targetDir,
    required List<String> dependencies,
    required List<String> devDependencies,
    required List<String> postHooks,
  }) async {
    if (fileService == null || pubspecService == null || hookService == null) {
      logger.error('FileService, PubspecService, and HookService are required');
      return false;
    }

    if (dependencies.isNotEmpty) {
      final installDepsProgress = logger.progress(
        'Adding dependencies for "$name"...',
      );
      try {
        await pubspecService!.addDependencies(
          path: targetDir.path,
          dependencies: dependencies,
        );
        installDepsProgress.complete('Dependencies added successfully');
      } catch (e) {
        installDepsProgress.fail('Failed adding dependencies: $e');
        return false;
      }
    }

    if (devDependencies.isNotEmpty) {
      final installDevDepsProgress = logger.progress(
        'Adding dev dependencies for "$name"...',
      );
      try {
        await pubspecService!.addDevDependencies(
          path: targetDir.path,
          devDependencies: devDependencies,
        );
        installDevDepsProgress.complete('Dev dependencies added successfully');
      } catch (e) {
        installDevDepsProgress.fail('Failed adding dev dependencies: $e');
        return false;
      }
    }

    if (postHooks.isNotEmpty) {
      final postHooksProgress = logger.progress(
        'Running post hooks for "$name"...',
      );
      try {
        await hookService!.runHook(
          hooks: postHooks,
          workingDirectory: targetDir.path,
        );
        postHooksProgress.complete('Post hooks executed successfully');
      } catch (e) {
        postHooksProgress.fail('Failed running post hooks: $e');
        return false;
      }
    }

    return true;
  }
}
