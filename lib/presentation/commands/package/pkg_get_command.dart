import '../../../domain/params/workspace_param.dart';
import '../../../infrastructure/services/package_sync_service.dart';
import '../wrapper/workspace_guard_command.dart';

class PkgGetCommand extends WorkspaceGuardCommand {
  final PackageSyncService packageSyncService;

  PkgGetCommand({
    required super.logger,
    required super.configService,
    required this.packageSyncService,
    required super.reportService,
    required super.directoryService,
  });

  @override
  String get name => 'get';

  @override
  String get description =>
      'Synchronize workspace packages based on active declarations in fsda.yaml.';

  @override
  String get invocation => 'fsda pkg get';

  @override
  Future<int> handle(WorkspaceParam workspace) async {
    final progress = logger.progress('Synchronizing packages...');

    try {
      await packageSyncService.syncPackages(
        onProgress: (msg) => progress.update(msg),
      );

      progress.update('Generating report...');
      final reportBuffer = reportService.generatePackageReport(
        operationLabel: 'Package Synchronization Summary',
      );

      progress.complete('Package synchronization completed!');
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to get packages: $e');
      return errorSystem;
    }
  }
}
