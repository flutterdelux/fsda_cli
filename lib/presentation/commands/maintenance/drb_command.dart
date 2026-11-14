import '../../../domain/models/target_maintenance_model.dart';
import '../../../infrastructure/services/maintenance/build_runner_service.dart';
import '../wrapper/maintenance_command.dart';

class DrbCommand extends MaintenanceCommand {
  final BuildRunnerService _buildRunnerService;

  DrbCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required BuildRunnerService buildRunnerService,
  }) : _buildRunnerService = buildRunnerService;

  @override
  String get name => 'drb';

  @override
  String get description =>
      'Runs "dart run build_runner build --delete-conflicting-outputs --force-jit" in the target module or app.';

  @override
  String get invocation =>
      'fsda $name [--module (-m) <module>] [--app (-a) <app>]';

  @override
  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets) async {
    for (final target in targets) {
      final progress = logger.progress(
        'Executing build_runner in ${target.type.value} "${target.name}"...',
      );

      try {
        await _buildRunnerService.runBuildRunner(
          target.path,
          onProgress: (msg) => progress.update(msg),
        );
        progress.complete(
          'build_runner completed successfully for ${target.type.value} "${target.name}"',
        );
      } catch (e) {
        progress.fail(
          'Failed to run build_runner for ${target.type.value} "${target.name}": $e',
        );

        // JIKA EROR: Langsung hentikan aplikasi dan return kode eror seketika
        return errorSystem;
      }
    }

    // jika SEMUA target berhasil lolos tanpa eror
    return successCode;
  }
}
