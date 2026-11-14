import '../../../infrastructure/bundles/package_bundle.dart';
import '../../../infrastructure/services/package_sync_service.dart';
import '../wrapper/workspace_guard_command.dart';

class PkgAddCommand extends WorkspaceGuardCommand {
  final PackageSyncService packageSyncService;

  PkgAddCommand({
    required super.logger,
    required super.configService,
    required this.packageSyncService,
    required super.reportService,
    required super.directoryService,
  });

  @override
  String get name => 'add';

  @override
  String get description =>
      'Add one or more packages to fsda.yaml and synchronize workspace.';

  @override
  String get invocation => 'fsda pkg add <pkg_1> <pkg_2> ...';

  @override
  Future<int> handle() async {
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      logger.error('Please specify at least one package to add.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    // 1. Validasi apakah semua paket yang diminta ada di packageBundle
    for (final pkg in rest) {
      if (!packageBundle.containsKey(pkg)) {
        logger.error('Package template "$pkg" does not exist in CLI bundles.');
        logger.log('Run "fsda pkg list" to see available packages.');
        return errorUsage;
      }
    }

    final progress = logger.progress('Adding packages to fsda.yaml...');

    try {
      // 2. Gunakan configService untuk menyisipkan paket ke posisi terakhir
      await configService.addPackages(rest);

      progress.update('Synchronizing packages...');

      // 3. Jalankan sinkronisasi otomatis
      await packageSyncService.syncPackages(
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generatePackageReport(
        operationLabel: 'Add Package Summary',
      );

      progress.complete('Packages successfully added and synchronized!');
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to add packages: $e');
      return errorSystem;
    }
  }
}
