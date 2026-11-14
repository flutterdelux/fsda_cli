import '../helpers/process_service.dart';

class RefreshService {
  final ProcessService _processService;

  const RefreshService({required ProcessService processService})
    : _processService = processService;

  Future<void> refresh(
    String path, {
    required Function(String) onProgress,
  }) async {
    // 1. Jalankan flutter clean
    onProgress('Running flutter clean at $path');
    await _processService.run('flutter', ['clean'], path);

    // 2. Jalankan flutter pub get
    onProgress('Running flutter pub get at $path');
    await _processService.run('flutter', ['pub', 'get'], path);
  }
}
