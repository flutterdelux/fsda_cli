import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../generated/package_bundle.dart';
import '../services/logger_service.dart';
import '../services/operation_report_service.dart';
import 'package_generator.dart';

class ConfigureGenerator {
  final LoggerService logger;
  final PackageGenerator packageGenerator;

  const ConfigureGenerator({
    required this.packageGenerator,
    required this.logger,
  });

  Future<void> generate() async {
    final report = OperationReportService();

    try {
      final configFile = File('fsda.yaml');
      if (!await configFile.exists()) {
        logger.error('fsda.yaml not found in current workspace.');
        return;
      }

      final yamlString = await configFile.readAsString();
      final doc = loadYaml(yamlString);

      if (doc is! YamlMap) {
        logger.error('Format fsda.yaml broken: expected a YAML map object.');
        return;
      }

      if (!doc.containsKey('packages')) {
        logger.error('Format fsda.yaml broken: Key "packages:" not found.');
        return;
      }

      final rawPackages = doc['packages'];
      if (rawPackages is! YamlList) {
        logger.error(
          'Format fsda.yaml broken: Key "packages:" must be a list.',
        );
        return;
      }

      final configuredPackages = rawPackages
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      final templatePackages = packageBundle.keys.toSet();

      final unknownConfigured =
          configuredPackages.difference(templatePackages).toList()..sort();
      if (unknownConfigured.isNotEmpty) {
        logger.info(
          'Ignoring unknown package template(s): ${unknownConfigured.join(', ')}',
        );
      }

      final desiredPackages = configuredPackages.intersection(templatePackages);

      final packagesDir = Directory(p.join(Directory.current.path, 'packages'));
      final beforeSnapshot = await _snapshotFileFingerprints(packagesDir.path);
      if (!await packagesDir.exists()) {
        await packagesDir.create(recursive: true);
        report.addCreated(packagesDir.path);
      }

      final existingPackages = <String>{};
      await for (final entity in packagesDir.list(followLinks: false)) {
        if (entity is Directory) {
          existingPackages.add(p.basename(entity.path));
        }
      }

      final managedExisting = existingPackages.intersection(templatePackages);
      final packagesToRemove =
          managedExisting.difference(desiredPackages).toList()..sort();
      final packagesToAdd =
          desiredPackages.difference(existingPackages).toList()..sort();
      final packagesKept =
          desiredPackages.intersection(existingPackages).toList()..sort();

      logger.info('Synchronizing workspace packages from fsda.yaml ...');

      for (final package in packagesToRemove) {
        final dir = Directory(p.join(packagesDir.path, package));
        if (!await dir.exists()) continue;
        await dir.delete(recursive: true);
        logger.info('Removed package "$package" from workspace/packages.');
      }

      final failedToAdd = <String>[];
      for (final package in packagesToAdd) {
        final created = await packageGenerator.generate(package);
        if (!created) {
          failedToAdd.add(package);
        }
      }

      logger.log('');
      logger.info('Configure summary:');
      logger.log('  + added   : ${packagesToAdd.length - failedToAdd.length}');
      logger.log('  - removed : ${packagesToRemove.length}');
      logger.log('  = kept    : ${packagesKept.length}');

      if (failedToAdd.isNotEmpty) {
        logger.error('Failed to add package(s): ${failedToAdd.join(', ')}');
        return;
      }

      final afterSnapshot = await _snapshotFileFingerprints(packagesDir.path);
      _appendSnapshotDiff(
        report: report,
        before: beforeSnapshot,
        after: afterSnapshot,
      );

      logger.success('Workspace packages have been synchronized successfully.');
      report.logSummary(logger, operationLabel: 'fsda configure');
    } catch (e) {
      logger.error('Failed to read fsda.yaml configuration: $e');
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
