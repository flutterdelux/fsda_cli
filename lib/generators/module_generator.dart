import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../generated/bricks/module_bundle.dart';
import '../services/operation_report_service.dart';
import '../services/sdk_service.dart';
import 'base_generator.dart';

const _dependencies = ['freezed_annotation', 'json_annotation', 'bloc'];

const _devDependencies = [
  'flutter_lints',
  'build_runner',
  'freezed',
  'json_serializable',
];

const _postHooks = [
  'flutter gen-l10n',
  'dart run build_runner build --force-jit --delete-conflicting-outputs',
];

class ModuleGenerator extends BaseGenerator<void, ({String module})> {
  final SdkService sdkService;

  ModuleGenerator({
    required this.sdkService,
    required super.pubspecService,
    required super.hookService,
    required super.logger,
    required super.fileService,
  });

  @override
  Future<void> generate(({String module}) args) async {
    final module = args.module;
    final report = OperationReportService();

    final nameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!nameRegExp.hasMatch(module)) {
      logger.error(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
      );
      return;
    }

    final targetDir = Directory(
      p.join(Directory.current.path, 'modules', module),
    );

    if (await targetDir.exists()) {
      logger.error('Module "$module" already exists at ${targetDir.path}');
      return;
    }

    try {
      final progress = logger.progress('Baking module "$module" via Mason...');
      final generator = await MasonGenerator.fromBundle(moduleBundle);
      final target = DirectoryGeneratorTarget(targetDir);

      final generatedFiles = await generator.generate(
        target,
        vars: <String, dynamic>{
          'module': module,
          'dart_sdk': sdkService.dartVersion,
        },
      );
      progress.complete(
        'Baked ${generatedFiles.length} files into modules/$module',
      );

      final templateSuccess = await generateTemplatePipeline(
        name: module,
        targetDir: targetDir,
        dependencies: _dependencies,
        devDependencies: _devDependencies,
        postHooks: _postHooks,
      );
      if (!templateSuccess) return;

      final createdFiles = await _collectFilesRecursively(targetDir.path);
      for (final filePath in createdFiles) {
        report.addCreated(filePath);
      }

      logger.success('Module "$module" created successfully');
      report.logSummary(logger, operationLabel: 'fsda gen-module');
    } catch (e) {
      logger.error('$e');
      return;
    }
  }

  Future<List<String>> _collectFilesRecursively(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      return const <String>[];
    }

    final files = <String>[];
    await for (final entity in rootDir.list(recursive: true)) {
      if (entity is File) {
        files.add(entity.path);
      }
    }

    files.sort();
    return files;
  }
}
