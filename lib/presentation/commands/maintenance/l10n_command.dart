import '../../../domain/models/target_maintenance_model.dart';
import '../../../infrastructure/services/maintenance/l10n_service.dart';
import '../wrapper/maintenance_command.dart';

class L10nCommand extends MaintenanceCommand {
  final L10nService _l10nService;

  L10nCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required L10nService l10nService,
  }) : _l10nService = l10nService;

  @override
  String get name => 'l10n';

  @override
  String get description =>
      'Runs "flutter gen-l10n" in the target module or app.';

  @override
  String get invocation =>
      'fsda $name [--module (-m) <module>] [--app (-a) <app>]';

  @override
  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets) async {
    for (final target in targets) {
      final progress = logger.progress(
        'Executing flutter gen-l10n in ${target.type.value} "${target.name}"...',
      );

      try {
        await _l10nService.runL10n(
          target.path,
          onProgress: (msg) => progress.update(msg),
        );
        progress.complete(
          'flutter gen-l10n completed successfully for ${target.type.value} "${target.name}"',
        );
      } catch (e) {
        progress.fail(
          'Failed to run flutter gen-l10n for ${target.type.value} "${target.name}": $e',
        );
        return errorSystem;
      }
    }

    return successCode;
  }
}
