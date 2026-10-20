import 'dart:io';

import 'package:args/command_runner.dart';

import '../services/hook_service.dart';
import '../services/logger_service.dart';

extension PostHookMapExtension on Map<dynamic, dynamic> {
  bool contains(dynamic key) => containsKey(key);
}

abstract class BaseCommand extends Command<void> {
  final HookService hookService;
  final LoggerService logger;

  BaseCommand({required this.hookService, required this.logger});

  Future<void> runPostHook(
    Map<String, dynamic> result, {
    required bool hookDisabled,
    String? operationLabel,
  }) async {
    if (!result.containsKey('post_hook')) return;
    final rawHooks = result['post_hook'];
    if (rawHooks is! List || rawHooks.isEmpty) return;

    final hooks = List<String>.from(rawHooks);
    final workingDirectory =
        result['working_directory'] as String? ?? Directory.current.path;

    await hookService.runHook(
      hooks: hooks,
      workingDirectory: workingDirectory,
      logger: logger,
      disabled: hookDisabled,
      operationLabel: operationLabel,
    );
  }

  Future<void> runAggregatedPostHooks(
    List<Map<String, dynamic>> results, {
    required bool hookDisabled,
    String? operationLabel,
  }) async {
    final hooksByDir = <String, Set<String>>{};
    for (final result in results) {
      if (!result.containsKey('post_hook')) continue;
      final rawHooks = result['post_hook'];
      if (rawHooks is! List || rawHooks.isEmpty) continue;

      final workingDir =
          result['working_directory'] as String? ?? Directory.current.path;
      hooksByDir
          .putIfAbsent(workingDir, () => <String>{})
          .addAll(rawHooks.map((e) => e.toString()));
    }

    for (final entry in hooksByDir.entries) {
      if (entry.value.isEmpty) continue;
      await hookService.runHook(
        hooks: entry.value.toList(growable: false),
        workingDirectory: entry.key,
        logger: logger,
        disabled: hookDisabled,
        operationLabel: operationLabel,
      );
    }
  }
}
