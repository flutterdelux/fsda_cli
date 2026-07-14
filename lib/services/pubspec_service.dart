import 'process_service.dart';

class PubspecService {
  final ProcessService processService;

  const PubspecService({required this.processService});

  Future<void> addDependencies({
    required String path,
    required List<String> dependencies,
  }) async {
    if (dependencies.isNotEmpty) {
      await processService.run(
        label: 'Add Dependencies',
        executable: 'dart',
        arguments: ['pub', 'add', ...dependencies],
        workingDirectory: path,
      );
    }
  }

  Future<void> addDevDependencies({
    required String path,
    required List<String> devDependencies,
  }) async {
    if (devDependencies.isNotEmpty) {
      await processService.run(
        label: 'Add Dev Dependencies',
        executable: 'dart',
        arguments: ['pub', 'add', '--dev', ...devDependencies],
        workingDirectory: path,
      );
    }
  }
}
