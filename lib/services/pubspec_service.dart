import 'logger_service.dart';
import 'process_service.dart';

class PubspecService {
  final ProcessService processService;
  final LoggerService logger;

  const PubspecService({required this.processService, required this.logger});

  Future<bool> addDependencies({
    required String path,
    required List<String> dependencies,
    required String operationLabel,
    bool forDev = false,
  }) async {
    final installDepsProgress = logger.progress(operationLabel);
    try {
      await processService.run(
        label: operationLabel,
        executable: 'dart',
        arguments: ['pub', 'add', if (forDev) '--dev', ...dependencies],
        workingDirectory: path,
      );
      installDepsProgress.complete('$operationLabel completed');
      return true;
    } catch (e) {
      installDepsProgress.fail('$operationLabel failed: $e');
      return false;
    }
  }
}
