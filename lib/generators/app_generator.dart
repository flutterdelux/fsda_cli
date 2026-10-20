import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_messages.dart';
import '../generated/bricks/app_bundle.dart';
import '../services/logger_service.dart';
import '../services/operation_report_service.dart';
import '../services/process_service.dart';
import '../services/pubspec_service.dart';
import '../services/sdk_service.dart';

const _dependencies = [
  'logging',
  'flutter_bloc',
  'get_it',
  'go_router',
  'collection',
  'intl',
];

const _devDependencies = [
  'flutter_lints',
  'flutter_launcher_icons',
  'package_rename',
];

class AppGenerator {
  final ProcessService processService;
  final LoggerService logger;
  final SdkService sdkService;
  final PubspecService pubspecService;
  final OperationReportService report;

  AppGenerator({
    required this.processService,
    required this.sdkService,
    required this.logger,
    required this.pubspecService,
    required this.report,
  });

  Future<void> generate(({String app}) args) async {
    final app = args.app;

    final targetDir = Directory(p.join(Directory.current.path, 'apps', app));

    if (await targetDir.exists()) {
      logger.error('App "$app" already exists');
      return;
    }

    try {
      /// Create flutter app using flutter create command
      final createAppProgress = logger.progress(
        'Creating Flutter app template for "$app"',
      );

      await processService.run(
        label: 'Create App',
        executable: 'flutter',
        arguments: ['create', '--project-name', app, targetDir.path],
        workingDirectory: Directory.current.path,
      );

      createAppProgress.complete('App template created successfully');

      /// remove folder test
      final testDir = Directory(p.join(targetDir.path, 'test'));
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }

      /// Baked template using Mason
      final progress = logger.progress('Baking app "$app"...');
      final generator = await MasonGenerator.fromBundle(appBundle);
      final target = DirectoryGeneratorTarget(targetDir);

      await generator.generate(
        target,
        vars: <String, dynamic>{'app': app, 'dart_sdk': sdkService.dartVersion},
      );
      progress.complete('Baked app template successfully');

      await pubspecService.addDependencies(
        path: targetDir.path,
        dependencies: _dependencies,
        operationLabel: 'Adding dependencies for $app',
      );
      // if (!dependencyAdded) return null;

      await pubspecService.addDependencies(
        path: targetDir.path,
        dependencies: _devDependencies,
        operationLabel: 'Adding dev dependencies for $app',
        forDev: true,
      );
      // if (!devDependencyAdded) return null;

      await _appendImportantCreatedPaths(
        report: report,
        appRoot: targetDir.path,
      );

      logger.success('App "$app" created successfully');
      report.logSummary(logger, operationLabel: 'fsda gen-app $app');

      logger.log(CliMessages.appGeneratedNextSteps(app));
    } catch (e) {
      logger.error(e.toString());
    }
  }

  Future<void> _appendImportantCreatedPaths({
    required OperationReportService report,
    required String appRoot,
  }) async {
    final appDir = Directory(appRoot);
    if (!await appDir.exists()) {
      return;
    }

    report.addCreated(appDir.path);

    final importantDirs = <String>['lib', 'assets/images', 'docs'];
    for (final relativePath in importantDirs) {
      final dir = Directory(p.join(appRoot, relativePath));
      if (!await dir.exists()) {
        continue;
      }
      report.addCreated(dir.path);
    }

    final importantFiles = <String>[
      'pubspec.yaml',
      'analysis_options.yaml',
      'flutter_launcher_icons.yaml',
      'package_rename_config.yaml',
    ];

    for (final relativePath in importantFiles) {
      final file = File(p.join(appRoot, relativePath));
      if (!await file.exists()) {
        continue;
      }
      report.addCreated(file.path);
    }
  }
}
