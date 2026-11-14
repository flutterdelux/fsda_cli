import '../helpers/process_service.dart';

class FixImportService {
  final ProcessService _processService;

  const FixImportService({required ProcessService processService})
    : _processService = processService;

  Future<void> fixImport(
    String path, {
    required Function(String) onProgress,
  }) async {
    onProgress('Fixing imports at $path...');

    await _processService.run('dart', [
      'fix',
      '--apply',
      '--code=directives_ordering',
      '--code=unused_import',
    ], path);
  }
}
