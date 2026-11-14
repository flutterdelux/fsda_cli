import 'build_runner_service.dart';
import 'l10n_service.dart';

class RebuildService {
  final BuildRunnerService _buildRunnerService;
  final L10nService _l10nService;

  const RebuildService({
    required BuildRunnerService buildRunnerService,
    required L10nService l10nService,
  }) : _buildRunnerService = buildRunnerService,
       _l10nService = l10nService;

  Future<void> rebuild(
    String path, {
    required Function(String) onProgress,
  }) async {
    // 1. Jalankan proses build_runner
    await _buildRunnerService.runBuildRunner(path, onProgress: onProgress);

    // 2. Lanjutkan dengan flutter gen-l10n
    await _l10nService.runL10n(path, onProgress: onProgress);
  }
}
