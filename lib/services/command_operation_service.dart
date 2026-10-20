import 'dart:collection';
import 'dart:io';

import 'hook_service.dart';
import 'logger_service.dart';
import 'operation_report_service.dart';

class CommandOperationService {
  final HookService hookService;
  final LoggerService logger;
  final OperationReportService report;

  const CommandOperationService({
    required this.hookService,
    required this.logger,
    required this.report,
  });

  Future<T> run<T>({
    required String operationLabel,
    required Future<T> Function() action,
    bool hookDisabled = false,
    List<Map<String, dynamic>> Function(T result)? hookResults,
  }) async {
    report.beginOperation();
    try {
      final result = await action();
      if (hookResults != null) {
        final results = hookResults(result);
        await _runPostHooks(results, operationLabel, hookDisabled);
      }
      return result;
    } finally {
      report.endOperation(logger, operationLabel: operationLabel);
    }
  }

  Future<void> _runPostHooks(
    List<Map<String, dynamic>> results,
    String operationLabel,
    bool hookDisabled,
  ) async {
    final hooksByDirectory = <String, LinkedHashSet<String>>{};
    for (final result in results) {
      if (result['success'] == false) continue;
      final rawHooks = result['post_hook'] ?? result['post_hooks'];
      if (rawHooks is! Iterable) continue;
      final workingDirectory =
          result['working_directory'] as String? ??
          result['dir'] as String? ??
          Directory.current.path;
      final hooks = hooksByDirectory.putIfAbsent(
        workingDirectory,
        LinkedHashSet<String>.new,
      );
      hooks.addAll(rawHooks.map((hook) => hook.toString()));
    }

    for (final entry in hooksByDirectory.entries) {
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
