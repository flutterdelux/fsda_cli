import '../../../infrastructure/services/package_sync_service.dart';
import '../wrapper/workspace_guard_command.dart';

class PkgRmCommand extends WorkspaceGuardCommand {
  final PackageSyncService packageSyncService;

  PkgRmCommand({
    required super.logger,
    required super.configService,
    required this.packageSyncService,
    required super.reportService,
    required super.directoryService,
  });

  @override
  String get name => 'rm';

  @override
  String get description =>
      'Remove one or more packages from fsda.yaml and synchronize workspace.';

  @override
  String get invocation => 'fsda pkg rm <pkg_1> <pkg_2> ...';

  @override
  Future<int> handle() async {
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      logger.error('Please specify at least one package to remove.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final progress = logger.progress('Removing packages from fsda.yaml...');

    try {
      await configService.removePackages(rest);

      progress.update('Synchronizing packages...');

      await packageSyncService.syncPackages(
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generatePackageReport(
        operationLabel: 'Remove Package Summary',
      );

      progress.complete('Packages successfully removed and synchronized!');
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove packages: $e');
      return errorSystem;
    }
  }
}
