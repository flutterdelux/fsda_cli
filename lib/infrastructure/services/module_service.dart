import '../../core/extensions/module_param_x.dart';
import '../../domain/params/module_param.dart';
import '../bundles/module_bundle.dart';
import 'helpers/config_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/mason_generator_service.dart';
import 'helpers/operation_report_service.dart';
import 'helpers/process_service.dart';
import 'maintenance/build_runner_service.dart';
import 'maintenance/l10n_service.dart';

class ModuleService {
  final ConfigService _configService;
  final ProcessService _processService;
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final BuildRunnerService _buildRunnerService;
  final L10nService _l10nService;
  final MasonGeneratorService _generatorService;

  static const _dependencies = [
    'freezed_annotation:"^3.1.0"',
    'json_annotation:"^4.12.0"',
    'bloc', // Default
    // 'get',
    // 'provider',
    // 'riverpod',
  ];

  static const _devDependencies = [
    'dev:flutter_lints',
    'dev:build_runner:"^2.15.1"',
    'dev:freezed:"^3.2.5"',
    'dev:json_serializable:"^6.14.1"',
  ];

  const ModuleService({
    required ConfigService configService,
    required ProcessService processService,
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required BuildRunnerService buildRunnerService,
    required L10nService l10nService,
    required MasonGeneratorService masonGeneratorService,
  }) : _configService = configService,
       _processService = processService,
       _reportService = reportService,
       _directoryService = directoryService,
       _buildRunnerService = buildRunnerService,
       _l10nService = l10nService,
       _generatorService = masonGeneratorService;

  Future<void> generate({
    required ModuleParam module,
    required Function(String) onProgress,
  }) async {
    onProgress('Reading FSDA configuration...');
    final config = await _configService.loadConfig();

    onProgress('Creating module directory...');
    await _createModuleDirectory(module);

    onProgress('Copying module bundle...');
    await _generatorService.generate(
      bundle: moduleBundle,
      targetPath: module.modulePath,
      vars: {'module': module.moduleName, 'dart_sdk': config.dartSdk},
    );

    onProgress('Installing package dependencies...');
    await _installDependencies(module);

    onProgress('Generating module builder...');
    await _buildRunnerService.runBuildRunner(
      module.modulePath,
      onProgress: onProgress,
    );

    onProgress('Generating module locatization...');
    await _l10nService.runL10n(module.modulePath, onProgress: onProgress);
  }

  // ================== Generation Helper ==================

  Future<void> _createModuleDirectory(ModuleParam module) async {
    await _directoryService.create(module.modulePath);
    _reportService.addCreated(module.modulePath);
  }

  Future<void> _installDependencies(ModuleParam module) async {
    if (_dependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        ..._dependencies,
      ], module.modulePath);
    }

    if (_devDependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        ..._devDependencies,
      ], module.modulePath);
    }
  }
}
