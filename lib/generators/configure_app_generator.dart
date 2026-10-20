import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../generated/package_bundle.dart';
import '../services/logger_service.dart';
import '../services/operation_report_service.dart';
import 'configure_app/app_dependency_installer.dart';
import 'configure_app/di_file_sync_service.dart';
import 'configure_app/infra_spec_bundle_reader.dart';
import 'configure_app/managed_package_dependency_sync.dart';

class ConfigureAppGenerator {
  final InfraSpecBundleReader infraSpecBundleReader;
  final ManagedPackageDependencySync managedPackageDependencySync;
  final DiFileSyncService diFileSyncService;
  final AppDependencyInstaller appDependencyInstaller;
  final LoggerService logger;
  final OperationReportService report;

  ConfigureAppGenerator({
    required this.logger,
    required this.infraSpecBundleReader,
    required this.managedPackageDependencySync,
    required this.diFileSyncService,
    required this.appDependencyInstaller,
    required this.report,
  });

  Future<void> generate(String appName) async {
    final appPath = p.join(Directory.current.path, 'apps', appName);
    final appPubspecFile = File(p.join(appPath, 'pubspec.yaml'));
    final coreDiPath = p.join(appPath, 'lib', 'core', 'di', 'core_di.dart');
    final externalDiPath = p.join(
      appPath,
      'lib',
      'core',
      'di',
      'external_di.dart',
    );
    final externalsDirPath = p.join(appPath, 'lib', 'core', 'externals');

    if (!await appPubspecFile.exists()) {
      logger.error('pubspec.yaml not found for app "$appName".');
      return;
    }

    final pubspecBefore = await _fileFingerprint(appPubspecFile.path);
    final coreDiBefore = await _fileFingerprint(coreDiPath);
    final externalDiBefore = await _fileFingerprint(externalDiPath);
    final externalsBefore = await _snapshotFileFingerprints(externalsDirPath);

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
    );
    final externalDiResult = await diFileSyncService.syncExternalDiFile(
      appPath: appPath,
      appName: appName,
      allInfraSpecs: infraSpecs,
      activeInfraSpecs: activeInfraSpecs,
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

    final pubspecAfter = await _fileFingerprint(appPubspecFile.path);
    final coreDiAfter = await _fileFingerprint(coreDiPath);
    final externalDiAfter = await _fileFingerprint(externalDiPath);
    final externalsAfter = await _snapshotFileFingerprints(externalsDirPath);

    _appendFileDiff(
      report: report,
      path: appPubspecFile.path,
      before: pubspecBefore,
      after: pubspecAfter,
    );
    _appendFileDiff(
      report: report,
      path: coreDiPath,
      before: coreDiBefore,
      after: coreDiAfter,
    );
    _appendFileDiff(
      report: report,
      path: externalDiPath,
      before: externalDiBefore,
      after: externalDiAfter,
    );
    _appendSnapshotDiff(
      report: report,
      before: externalsBefore,
      after: externalsAfter,
    );

    logger.success('App "$appName" package dependencies are synchronized.');
    report.logSummary(logger, operationLabel: 'fsda configure-app $appName');
  }

  Future<Set<String>> _collectWorkspacePackages() async {
    final configFile = File('fsda.yaml');
    if (!await configFile.exists()) return <String>{};

    try {
      final yamlString = await configFile.readAsString();
      final doc = loadYaml(yamlString);
      if (doc is! YamlMap || !doc.containsKey('packages')) {
        return <String>{};
      }

      final rawPackages = doc['packages'];
      if (rawPackages is! YamlList) {
        return <String>{};
      }

      // Mengambil paket yang terdaftar dan tidak kosong di fsda.yaml
      return rawPackages
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<Map<String, int>> _snapshotFileFingerprints(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      return const <String, int>{};
    }

    final snapshot = <String, int>{};
    await for (final entity in rootDir.list(recursive: true)) {
      if (entity is! File) {
        continue;
      }

      final bytes = await entity.readAsBytes();
      snapshot[entity.path] = _fingerprintBytes(bytes);
    }

    return snapshot;
  }

  Future<int?> _fileFingerprint(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    return _fingerprintBytes(bytes);
  }

  void _appendFileDiff({
    required OperationReportService report,
    required String path,
    required int? before,
    required int? after,
  }) {
    if (before == null && after == null) {
      return;
    }

    if (before == null && after != null) {
      report.addCreated(path);
      return;
    }

    if (before != null && after == null) {
      report.addRemoved(path);
      return;
    }

    if (before != after) {
      report.addUpdated(path);
    }
  }

  void _appendSnapshotDiff({
    required OperationReportService report,
    required Map<String, int> before,
    required Map<String, int> after,
  }) {
    for (final entry in after.entries) {
      final previous = before[entry.key];
      if (previous == null) {
        report.addCreated(entry.key);
        continue;
      }

      if (previous != entry.value) {
        report.addUpdated(entry.key);
      }
    }

    for (final removedPath in before.keys) {
      if (!after.containsKey(removedPath)) {
        report.addRemoved(removedPath);
      }
    }
  }

  int _fingerprintBytes(List<int> bytes) {
    var hash = 17;
    for (final byte in bytes) {
      hash = 37 * hash + byte;
    }

    return hash;
  }
}
