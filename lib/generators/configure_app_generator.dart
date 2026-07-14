import 'dart:io';

import 'package:path/path.dart' as p;

import '../generated/package_bundle.dart';
import '../services/process_service.dart';
import 'base_generator.dart';
import 'configure_app/app_dependency_installer.dart';
import 'configure_app/di_file_sync_service.dart';
import 'configure_app/infra_spec_bundle_reader.dart';
import 'configure_app/managed_package_dependency_sync.dart';

class ConfigureAppGenerator extends BaseGenerator<void, String> {
  final InfraSpecBundleReader infraSpecBundleReader;
  final ManagedPackageDependencySync managedPackageDependencySync;
  final DiFileSyncService diFileSyncService;
  late final AppDependencyInstaller appDependencyInstaller;

  ConfigureAppGenerator({
    required super.logger,
    required ProcessService processService,
    InfraSpecBundleReader? infraSpecBundleReader,
    ManagedPackageDependencySync? managedPackageDependencySync,
    DiFileSyncService? diFileSyncService,
    AppDependencyInstaller? appDependencyInstaller,
  }) : infraSpecBundleReader =
           infraSpecBundleReader ?? const InfraSpecBundleReader(),
       managedPackageDependencySync =
           managedPackageDependencySync ?? const ManagedPackageDependencySync(),
       diFileSyncService = diFileSyncService ?? const DiFileSyncService() {
    this.appDependencyInstaller =
        appDependencyInstaller ??
        AppDependencyInstaller(processService: processService);
  }

  @override
  Future<void> generate(String appName) async {
    final appPath = p.join(Directory.current.path, 'apps', appName);
    final appPubspecFile = File(p.join(appPath, 'pubspec.yaml'));

    if (!await appPubspecFile.exists()) {
      logger.error('pubspec.yaml not found for app "$appName".');
      return;
    }

    final templatePackages = packageBundle.keys.toSet();
    final workspacePackages = await _collectWorkspacePackages();

    final infraTemplatePackages = templatePackages
        .where((name) => name.startsWith('infra_'))
        .toSet();
    final infraSpecs = infraSpecBundleReader.readInfraSpecs(
      infraTemplatePackages: infraTemplatePackages,
    );
    final activeInfraSpecs =
        infraSpecs
            .where((spec) => workspacePackages.contains(spec.packageName))
            .toList()
          ..sort((a, b) => a.packageName.compareTo(b.packageName));

    final unmanagedWorkspace =
        workspacePackages.difference(templatePackages).toList()..sort();
    if (unmanagedWorkspace.isNotEmpty) {
      logger.info(
        'Ignoring non-template workspace package(s): ${unmanagedWorkspace.join(', ')}',
      );
    }

    final managedPackagesToKeep = templatePackages.intersection(
      workspacePackages,
    );
    final managedPackagesToRemove = templatePackages.difference(
      workspacePackages,
    );

    final originalLines = await appPubspecFile.readAsLines();
    final packageSyncResult = managedPackageDependencySync.sync(
      lines: originalLines,
      managedPackagesToKeep: managedPackagesToKeep,
      managedPackagesToRemove: managedPackagesToRemove,
    );

    final originalContent = '${originalLines.join('\n')}\n';
    final updatedContent = '${packageSyncResult.updatedLines.join('\n')}\n';

    if (updatedContent != originalContent) {
      await appPubspecFile.writeAsString(updatedContent);
    }

    final desiredAppDependencies = <String>{
      for (final spec in activeInfraSpecs) ...spec.appDependencies,
    };
    final addedAppDependencies = await appDependencyInstaller
        .addMissingDependencies(
          appPath: appPath,
          pubspecLines: packageSyncResult.updatedLines,
          desiredDependencies: desiredAppDependencies,
        );

    final coreDiResult = await diFileSyncService.syncCoreDiFile(
      appPath: appPath,
      appName: appName,
      allInfraSpecs: infraSpecs,
      activeInfraSpecs: activeInfraSpecs,
      logger: logger,
    );
    final externalDiResult = await diFileSyncService.syncExternalDiFile(
      appPath: appPath,
      appName: appName,
      allInfraSpecs: infraSpecs,
      activeInfraSpecs: activeInfraSpecs,
      logger: logger,
    );

    logger.info('Configure-app summary for "$appName":');
    logger.log(
      '  + added   : ${packageSyncResult.added.length} share packages',
    );
    logger.log(
      '  - removed : ${packageSyncResult.removed.length} share packages',
    );
    final keptExisting =
        managedPackagesToKeep.length - packageSyncResult.added.length;
    logger.log(
      '  = keep    : ${keptExisting < 0 ? 0 : keptExisting} share packages',
    );
    logger.log('  + app dep : ${addedAppDependencies.length} pub package');
    logger.log(
      '  + core di : ${coreDiResult.added}, - core di: ${coreDiResult.removed}',
    );
    logger.log(
      '  + ext di  : ${externalDiResult.functionAdded}, - ext di : ${externalDiResult.functionRemoved}',
    );
    logger.log(
      '  + ext cfg : ${externalDiResult.fileAdded}, - ext cfg: ${externalDiResult.fileRemoved}',
    );

    if (packageSyncResult.added.isNotEmpty) {
      logger.log('  added package(s): ${packageSyncResult.added.join(', ')}');
    }
    if (packageSyncResult.removed.isNotEmpty) {
      logger.log(
        '  removed package(s): ${packageSyncResult.removed.join(', ')}',
      );
    }
    if (addedAppDependencies.isNotEmpty) {
      logger.log(
        '  added app dependency(s): ${addedAppDependencies.join(', ')}',
      );
    }

    logger.success('App "$appName" package dependencies are synchronized.');
  }

  Future<Set<String>> _collectWorkspacePackages() async {
    final packagesDir = Directory(p.join(Directory.current.path, 'packages'));
    if (!await packagesDir.exists()) return <String>{};

    final packageNames = <String>{};
    await for (final entity in packagesDir.list(followLinks: false)) {
      if (entity is Directory) {
        packageNames.add(p.basename(entity.path));
      }
    }

    return packageNames;
  }
}
