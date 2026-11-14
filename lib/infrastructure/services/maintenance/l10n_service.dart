import '../helpers/process_service.dart';

class L10nService {
  final ProcessService _processService;

  const L10nService({required ProcessService processService})
    : _processService = processService;

  Future<void> runL10n(
    String path, {
    required Function(String) onProgress,
  }) async {
    onProgress('Running flutter gen-l10n at $path');

    await _processService.run('flutter', ['gen-l10n'], path);
  }
}
