import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../generated/package_bundle.dart';
import '../services/logger_service.dart';
import 'package_generator.dart';

class ConfigureGenerator {
  static const _divider =
      '------------------------------------------------------------';

  final LoggerService logger;
  final PackageGenerator packageGenerator;

  const ConfigureGenerator({
    required this.packageGenerator,
    required this.logger,
  });

  Future<void> generate() async {
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
      if (!await packagesDir.exists()) {
        await packagesDir.create(recursive: true);
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

      logger.log(_divider);
      logger.info('Configure summary:');
      logger.log('  + added   : ${packagesToAdd.length - failedToAdd.length}');
      logger.log('  - removed : ${packagesToRemove.length}');
      logger.log('  = kept    : ${packagesKept.length}');

      if (failedToAdd.isNotEmpty) {
        logger.error('Failed to add package(s): ${failedToAdd.join(', ')}');
        return;
      }

      final addedPackages =
          packagesToAdd
              .where((package) => !failedToAdd.contains(package))
              .toList()
            ..sort();

      logger.log('');
      logger.info('Affected shared packages for fsda configure:');
      _logPackageSection(label: 'added', packages: addedPackages);
      _logPackageSection(label: 'removed', packages: packagesToRemove);
      logger.log(_divider);

      logger.success('Workspace packages have been synchronized successfully.');
    } catch (e) {
      logger.error('Failed to read fsda.yaml configuration: $e');
    }
  }

  void _logPackageSection({
    required String label,
    required List<String> packages,
  }) {
    logger.log('- $label (${packages.length})');
    if (packages.isEmpty) {
      logger.log('  (none)');
      return;
    }

    logger.log('  ${packages.join(', ')}');
  }
}
