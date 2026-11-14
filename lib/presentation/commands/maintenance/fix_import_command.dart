import '../../../domain/models/target_maintenance_model.dart';
import '../../../infrastructure/services/maintenance/fix_import_service.dart';
import '../wrapper/maintenance_command.dart';

class FixImportCommand extends MaintenanceCommand {
  final FixImportService _fixImportService;

  FixImportCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required FixImportService fixImportService,
  }) : _fixImportService = fixImportService;

  @override
  String get name => 'fix-import';

  @override
  String get description =>
      'Fixes and organizes imports in the target module, app, or both.';

  @override
  String get invocation =>
      'fsda $name [--module (-m) <module>] [--app (-a) <app>]';

  @override
  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets) async {
    for (final target in targets) {
      final progress = logger.progress(
        'Fixing imports in ${target.type.value} "${target.name}"...',
      );

      try {
        await _fixImportService.fixImport(
          target.path,
          onProgress: (msg) => progress.update(msg),
        );

        progress.complete(
          'Imports successfully fixed for ${target.type.value} "${target.name}"',
        );
      } catch (e) {
        progress.fail(
          'Failed to fix imports for ${target.type.value} "${target.name}": $e',
        );
        return errorSystem;
      }
    }

    return successCode;
  }
}
