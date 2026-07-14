import 'dart:io';

import 'package:path/path.dart' as p;

import '../generated/package_bundle.dart';
import '../services/bundle_service.dart';
import '../services/process_service.dart';
import 'base_generator.dart';

class PackageGenerator extends BaseGenerator<bool, String> {
  final ProcessService processService;
  final BundleService bundleService;

  PackageGenerator({
    required super.logger,
    required this.processService,
    required super.pubspecService,
    required super.fileService,
    required super.hookService,
    required this.bundleService,
  });

  @override
  Future<bool> generate(String packageName) async {
    if (packageName.isEmpty) {
      logger.error('Package name is required');
      return false;
    }

    final targetDir = Directory(
      p.join(Directory.current.path, 'packages', packageName),
    );

    if (await targetDir.exists()) {
      logger.error('Package "$packageName" already exists');
      return false;
    }

    final targetPath = p.join(Directory.current.path, 'packages', packageName);

    logger.info('---------- Creating package "$packageName" ----------');

    try {
      final template = await bundleService.unpackAndBake(
        bundleMap: packageBundle,
        templateName: packageName,
        targetPath: targetPath,
      );

      final templateSuccess = await generateTemplatePipeline(
        name: packageName,
        targetDir: targetDir,
        dependencies: template.spec.dependencies,
        devDependencies: template.spec.devDependencies,
        postHooks: template.spec.postHooks,
      );
      if (!templateSuccess) return false;

      logger.success(
        'Package $packageName has been successfully created at $targetPath',
      );
      return true;
    } catch (e) {
      logger.error('$e');
      return false;
    }
  }
}
