import 'package:path/path.dart' as p;

import '../../domain/models/config_model.dart';
import '../../domain/params/app_param.dart';
import '../bundles/app_bundle.dart';
import 'helpers/config_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/mason_generator_service.dart';
import 'helpers/operation_report_service.dart';
import 'helpers/process_service.dart';

class AppService {
  final ConfigService _configService;
  final ProcessService _processService;
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final FileService _fileService;
  final MasonGeneratorService _generatorService;

  static const _dependencies = [
    'logging',
    'flutter_bloc',
    'provider',
    'get',
    'flutter_riverpod',
    'get_it',
    'go_router',
    'collection',
    'intl',
  ];

  static const _devDependencies = [
    'flutter_lints',
    'flutter_launcher_icons',
    'package_rename',
  ];

  const AppService({
    required ConfigService configService,
    required ProcessService processService,
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required FileService fileService,
    required MasonGeneratorService generatorService,
  }) : _configService = configService,
       _processService = processService,
       _reportService = reportService,
       _directoryService = directoryService,
       _fileService = fileService,
       _generatorService = generatorService;

  Future<void> generateApp({
    required AppParam app,
    required Function(String) onProgress,
  }) async {
    onProgress('Reading FSDA configuration...');
    final config = await _configService.loadConfig();

    onProgress('Running flutter create for "${app.projectName}"...');
    await _createFlutterProject(app);

    onProgress('Cleaning up default test directory...');
    await _deleteTestDir(app);

    onProgress('Copying app bundle...');
    await _generatorService.generate(
      bundle: appBundle,
      targetPath: app.projectPath,
      vars: {
        'app': app.projectName,
        'app_name': app.appName,
        'org': app.org,
        'org_name': app.orgName,
        'dart_sdk': config.sdkVersion,
        'android_min_sdk': config.android.minSdk,
      },
    );

    onProgress('Configuring Android SDK versions in build.gradle.kts...');
    await _updateAndroidGradle(app, config);

    onProgress('Installing package dependencies...');
    await _installDependencies(app);
  }

  // ================= Gen App Helper ========================

  Future<void> _createFlutterProject(AppParam app) async {
    await _processService.run('flutter', [
      'create',
      '--org',
      app.org,
      app.projectName,
    ], p.dirname(app.projectPath));
    _reportService.addCreated(app.projectPath);
  }

  Future<void> _deleteTestDir(AppParam app) async {
    final testPath = p.join(app.projectPath, 'test');
    if (await _directoryService.exists(testPath)) {
      await _directoryService.delete(testPath);
      _reportService.addRemoved(testPath);
    }
  }

  Future<void> _updateAndroidGradle(AppParam app, ConfigModel config) async {
    final gradlePath = p.join(
      app.projectPath,
      'android',
      'app',
      'build.gradle.kts',
    );

    if (!await _fileService.exists(gradlePath)) return;

    String content = await _fileService.readAsString(gradlePath);

    // Menggunakan regex yang fleksibel: menangkap minSdk/targetSdk/compileSdk
    // apa pun nilai di sisi kanan operator '=' (baik berupa variabel flutter maupun angka statis)
    content = content.replaceFirst(
      RegExp(r'\bcompileSdk\s*=.*'),
      'compileSdk = ${config.android.compileSdk}',
    );
    content = content.replaceFirst(
      RegExp(r'\bminSdk\s*=.*'),
      'minSdk = ${config.android.minSdk}',
    );
    content = content.replaceFirst(
      RegExp(r'\btargetSdk\s*=.*'),
      'targetSdk = ${config.android.targetSdk}',
    );

    await _fileService.writeAsString(path: gradlePath, content: content);
    _reportService.addInjected(gradlePath);
  }

  Future<void> _installDependencies(AppParam app) async {
    if (_dependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        ..._dependencies,
      ], app.projectPath);
    }

    if (_devDependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        '--dev',
        ..._devDependencies,
      ], app.projectPath);
    }
  }
}
