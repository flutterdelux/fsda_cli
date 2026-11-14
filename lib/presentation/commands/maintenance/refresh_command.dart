import '../../../domain/models/target_maintenance_model.dart';
import '../../../infrastructure/services/maintenance/refresh_service.dart';
import '../../../infrastructure/text_modifiers/string_extension.dart';
import '../wrapper/maintenance_command.dart';

class RefreshCommand extends MaintenanceCommand {
  final RefreshService _refreshService;

  RefreshCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required RefreshService refreshService,
  }) : _refreshService = refreshService;

  @override
  String get name => 'refresh';

  @override
  String get description =>
      'Runs "flutter clean" and "flutter pub get" sequentially in the target module or app.';

  @override
  String get invocation =>
      'fsda $name [--module (-m) <module>] [--app (-a) <app>]';

  @override
  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets) async {
    for (final target in targets) {
      final progress = logger.progress(
        'Refreshing ${target.type.value} "${target.name}" (flutter clean & pub get)...',
      );

      try {
        await _refreshService.refresh(
          target.path,
          onProgress: (msg) => progress.update(msg),
        );

        progress.complete(
          '${target.type.value.capitalCase} "${target.name}" successfully refreshed!',
        );
      } catch (e) {
        progress.fail(
          'Failed to refresh ${target.type.value} "${target.name}": $e',
        );
        return errorSystem;
      }
    }

    return successCode;
  }
}
