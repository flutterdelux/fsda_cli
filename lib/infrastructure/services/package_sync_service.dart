import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../domain/models/config_model.dart';
import '../bundles/package_bundle.dart';
import 'helpers/config_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/operation_report_service.dart';
import 'helpers/process_service.dart';

class PackageSyncService {
  final ConfigService _configService;
  final OperationReportService _reportService;
  final ProcessService _processService;
  final DirectoryService _directoryService;
  final FileService _fileService;

  const PackageSyncService({
    required ConfigService configService,
    required OperationReportService reportService,
    required ProcessService processService,
    required DirectoryService directoryService,
    required FileService fileService,
  }) : _configService = configService,
       _reportService = reportService,
       _processService = processService,
       _directoryService = directoryService,
       _fileService = fileService;

  Future<void> syncPackages({required Function(String) onProgress}) async {
    onProgress('Reading FSDA configuration...');
    final config = await _configService.loadConfig();

    final packagesPath = p.join(_directoryService.currentPath, 'packages');

    final allBundledPackages = packageBundle.keys.toSet();
    final activePackages = config.activePackages.toSet();

    // 1. Proses Active Packages (Tambah jika belum ada, Retain jika sudah ada)
    for (final pkgName in activePackages) {
      final pkgPath = p.join(packagesPath, pkgName);

      if (await _directoryService.exists(pkgPath)) {
        onProgress('Retaining package "$pkgName"...');
        _reportService.addRetainedPackages(pkgPath);
      } else {
        onProgress('Adding package "$pkgName"...');
        await _copyPackageFromBundle(
          pkgName: pkgName,
          pkgPath: pkgPath,
          config: config,
        );
        _reportService.addAddedPackages(pkgPath);
      }
    }

    // 2. Proses Non-Active Packages (Hapus dari workspace/packages/ jika dikomentari/nonaktif)
    final inactivePackages = allBundledPackages.difference(activePackages);
    for (final pkgName in inactivePackages) {
      final pkgPath = p.join(packagesPath, pkgName);

      if (await _directoryService.exists(pkgPath)) {
        onProgress('Removing package "$pkgName"...');
        await _directoryService.delete(pkgPath);
        _reportService.addRemovedPackages(pkgPath);
      }
    }
  }

  Future<void> _copyPackageFromBundle({
    required String pkgName,
    required String pkgPath,
    required ConfigModel config,
  }) async {
    final filesMap = packageBundle[pkgName];
    if (filesMap == null) return;

    List<String> dependencies = [];
    List<String> devDependencies = [];
    List<String> postHooks = [];

    // First pass: extract spec.yaml contents and write other files
    for (final entry in filesMap.entries) {
      final relativePath = entry.key;

      // Jika file adalah spec.yaml, ambil isinya dan jangan disalin ke target directory
      if (relativePath == 'spec.yaml') {
        final bytes = base64.decode(entry.value);
        final content = utf8.decode(bytes, allowMalformed: true);
        final yamlMap = loadYaml(content) as YamlMap?;

        if (yamlMap != null) {
          if (yamlMap['dependencies'] is YamlList) {
            dependencies = (yamlMap['dependencies'] as YamlList)
                .map((e) => e.toString())
                .toList();
          }
          if (yamlMap['dev_dependencies'] is YamlList) {
            devDependencies = (yamlMap['dev_dependencies'] as YamlList)
                .map((e) => e.toString())
                .toList();
          }
          if (yamlMap['post_hooks'] is YamlList) {
            postHooks = (yamlMap['post_hooks'] as YamlList)
                .map((e) => e.toString())
                .toList();
          }
        }
        continue;
      }

      final bytes = base64.decode(entry.value);
      String decodedContent = utf8.decode(bytes, allowMalformed: true);

      // Jika file adalah pubspec.yaml, inject sdk_version dari workspace
      if (relativePath == 'pubspec.yaml') {
        final lines = decodedContent.split('\n');
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].trim().startsWith('sdk:')) {
            lines[i] = '  sdk: ${config.sdkVersion}';
            break;
          }
        }
        decodedContent = lines.join('\n');
      }

      final path = p.join(pkgPath, relativePath);
      await _directoryService.create(p.dirname(path));
      await _fileService.writeAsString(path: path, content: decodedContent);
    }

    await _executePackageHooks(
      pkgPath,
      dependencies,
      devDependencies,
      postHooks,
    );
  }

  Future<void> _executePackageHooks(
    String targetPath,
    List<String> dependencies,
    List<String> devDependencies,
    List<String> postHooks,
  ) async {
    if (dependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        ...dependencies,
      ], targetPath);
    }

    if (devDependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        '--dev',
        ...devDependencies,
      ], targetPath);
    }

    for (final hook in postHooks) {
      final parts = hook.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        await _processService.run(
          parts.first,
          parts.skip(1).toList(),
          targetPath,
        );
      }
    }
  }
}
