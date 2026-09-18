import 'logger_service.dart';
import 'process_service.dart';

class HookService {
  static const _divider =
      '------------------------------------------------------------';
  static const _defaultHookTimeout = Duration(seconds: 30);

  final ProcessService processService;
  const HookService({required this.processService});

  Future<void> runHook({
    required List<String> hooks,
    required String workingDirectory,
    required LoggerService logger,
    bool disabled = false,
    String? operationLabel,
    Duration timeout = _defaultHookTimeout,
  }) async {
    final normalizedHooks = hooks
        .map(_normalizeHookCommand)
        .where((hook) => hook.isNotEmpty)
        .toList(growable: false);

    if (normalizedHooks.isEmpty) {
      return;
    }

    if (disabled) {
      logger.log(_divider);
      logger.info(
        'Post hooks are skipped${operationLabel == null ? '' : ' for $operationLabel'} because --hook-disabled is set.',
      );
      logger.info('Next step (run manually):');
      logger.log('  cd $workingDirectory');
      for (var index = 0; index < normalizedHooks.length; index++) {
        logger.log('  ${index + 1}. ${normalizedHooks[index]}');
      }
      logger.log(_divider);
      return;
    }

    for (final hook in normalizedHooks) {
      if (hook.trim().isEmpty) continue;

      final hookName = hook.split(' ').length > 3
          ? '${hook.split(' ').take(3).join(' ')} ...'
          : hook;

      final progress = logger.progress('Running Hook: $hookName');
      try {
        await processService.runCommandString(
          label: 'Run Hook: $hookName',
          commandString: hook,
          workingDirectory: workingDirectory,
          timeout: timeout,
        );

        progress.complete('Hook completed: $hookName');
      } catch (e) {
        progress.fail(
          'Hook failed: $hookName. Use --hook-disabled to skip hooks and run them manually.',
        );
        rethrow;
      }
    }
  }

  String _normalizeHookCommand(String hook) {
    return hook.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }
}
