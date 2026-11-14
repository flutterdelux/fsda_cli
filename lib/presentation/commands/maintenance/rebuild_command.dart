import '../../../domain/models/target_maintenance_model.dart';
import '../../../infrastructure/services/maintenance/rebuild_service.dart';
import '../../../infrastructure/text_modifiers/string_extension.dart';
import '../wrapper/maintenance_command.dart';

class RebuildCommand extends MaintenanceCommand {
  final RebuildService _rebuildService;

  RebuildCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required RebuildService rebuildService,
  }) : _rebuildService = rebuildService;

  @override
  String get name => 'rebuild';

  @override
  String get description =>
      'Runs both build_runner and flutter gen-l10n sequentially in the target module or app.';

  @override
  String get invocation =>
      'fsda $name [--module (-m) <module>] [--app (-a) <app>]';

  @override
  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets) async {
    for (final target in targets) {
      final progress = logger.progress(
        'Rebuilding ${target.type.value} "${target.name}" (build_runner & l10n)...',
      );

      try {
        await _rebuildService.rebuild(
          target.path,
          onProgress: (msg) => progress.update(msg),
        );

        progress.complete(
          '${target.type.value.capitalCase} "${target.name}" successfully rebuilt!',
        );
      } catch (e) {
        progress.fail(
          'Failed to rebuild ${target.type.value} "${target.name}": $e',
        );
        return errorSystem;
      }
    }

    return successCode;
  }
}
