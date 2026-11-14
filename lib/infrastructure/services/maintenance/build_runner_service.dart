import '../helpers/process_service.dart';

class BuildRunnerService {
  final ProcessService _processService;

  const BuildRunnerService({required ProcessService processService})
    : _processService = processService;

  Future<void> runBuildRunner(
    String path, {
    required Function(String) onProgress,
  }) async {
    onProgress('Running build_runner at $path');

    await _processService.run('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
      '--force-jit',
    ], path);
  }
}
