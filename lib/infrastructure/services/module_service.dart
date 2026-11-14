import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/config_model.dart';
import '../../domain/params/module_param.dart';
import '../bundles/module_bundle.dart';
import 'helpers/config_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/operation_report_service.dart';
import 'helpers/process_service.dart';

class ModuleService {
  final ConfigService _configService;
  final ProcessService _processService;
  final OperationReportService _reportService;
  final DirectoryService _directoryService;

  static const _dependencies = [
    'freezed_annotation',
    'json_annotation',
    'bloc', // Default
    // 'get',
    // 'provider',
    // 'riverpod',
  ];

  static const _devDependencies = [
    'flutter_lints',
    'build_runner',
    'freezed',
    'json_serializable',
  ];

  const ModuleService({
    required ConfigService configService,
    required ProcessService processService,
    required OperationReportService reportService,
    required DirectoryService directoryService,
  }) : _configService = configService,
       _processService = processService,
       _reportService = reportService,
       _directoryService = directoryService;

  Future<void> generate({
    required ModuleParam module,
    required Function(String) onProgress,
  }) async {
    onProgress('Reading FSDA configuration...');
    final config = await _configService.loadConfig();

    onProgress('Creating module directory...');
    await _createModuleDirectory(module);

    onProgress('Copying module bundle...');
    await _copyModuleBundle(module, config);

    onProgress('Installing package dependencies...');
    await _installDependencies(module);
  }

  // ================== Generation Helper ==================

  Future<void> _createModuleDirectory(ModuleParam module) async {
    await _directoryService.create(module.path);
    _reportService.addCreated(module.path);
  }

  Future<void> _copyModuleBundle(ModuleParam module, ConfigModel config) async {
    try {
      final generator = await MasonGenerator.fromBundle(moduleBundle);
      final generatedFiles = await generator.generate(
        DirectoryGeneratorTarget(_directoryService.dirOf(module.path)),
        vars: {'module': module.name, 'dart_sdk': config.sdkVersion},
      );
      for (final file in generatedFiles) {
        final filePath = file.path;

        if (filePath.endsWith('.freezed.dart') ||
            filePath.endsWith('.g.dart')) {
          continue;
        }

        if (filePath.endsWith('.gitkeep')) {
          final folderPath = p.dirname(filePath);
          _reportService.addCreated(folderPath);
          continue;
        }

        _reportService.addCreated(filePath);
      }
    } catch (e) {
      throw Exception('Failed to generate module files: $e');
    }
  }

  Future<void> _installDependencies(ModuleParam module) async {
    if (_dependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        ..._dependencies,
      ], module.path);
    }

    if (_devDependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        '--dev',
        ..._devDependencies,
      ], module.path);
    }
  }
}
