import 'process_service.dart';

class HookService {
  final ProcessService processService;
  const HookService({required this.processService});

  Future<void> runHook({
    required List<String> hooks,
    required String workingDirectory,
  }) async {
    for (final hook in hooks) {
      if (hook.trim().isEmpty) continue;

      final hookName = hook.split(' ').length > 3
          ? '${hook.split(' ').take(3).join(' ')} ...'
          : hook;

      await processService.runCommandString(
        label: 'Run Hook: $hookName',
        commandString: hook,
        workingDirectory: workingDirectory,
      );
    }
  }
}
