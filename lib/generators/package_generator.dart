import 'dart:io';

import 'package:path/path.dart' as p;

import '../generated/package_bundle.dart';
import '../services/bundle_service.dart';
import '../services/file_service.dart';
import '../services/logger_service.dart';
import '../services/pubspec_service.dart';

class PackageGenerator {
  final BundleService bundleService;
  final LoggerService logger;
  final FileService fileService;
  final PubspecService pubspecService;

  PackageGenerator({
    required this.bundleService,
    required this.logger,
    required this.fileService,
    required this.pubspecService,
  });

  Future<Map<String, dynamic>?> generate(String packageName) async {
    if (packageName.isEmpty) {
      logger.error('Package name is required');
      return null;
    }

    if (!packageBundle.containsKey(packageName)) {
      logger.error(
        'Package template "$packageName" not found. Use "fsda list-pckg" to see available templates.',
      );
      return null;
    }

    final targetDir = Directory(
      p.join(Directory.current.path, 'packages', packageName),
    );

    if (await targetDir.exists()) {
      logger.error('Package "$packageName" already exists');
      return null;
    }

    final targetPath = p.join(Directory.current.path, 'packages', packageName);

    logger.info('---------- Creating package "$packageName" ----------');

    try {
      final template = await bundleService.unpackAndBake(
        bundleMap: packageBundle,
        templateName: packageName,
        targetPath: targetPath,
      );

      template.spec.postHooks;

      await pubspecService.addDependencies(
        path: targetPath,
        dependencies: template.spec.dependencies,
        operationLabel: 'Adding dependencies for $packageName',
      );
      // if (!dependencyAdded) return null;

      await pubspecService.addDependencies(
        path: targetPath,
        dependencies: template.spec.devDependencies,
        operationLabel: 'Adding dev dependencies for $packageName',
        forDev: true,
      );
      // if (!devDependencyAdded) return null;

      logger.success(
        'Package $packageName has been successfully created at $targetPath',
      );
      return {'post_hooks': template.spec.postHooks, 'dir': targetPath};
    } catch (e) {
      logger.error('$e');
      return null;
    }
  }
}
