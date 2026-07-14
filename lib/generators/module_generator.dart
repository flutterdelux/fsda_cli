import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../generated/bricks/module_bundle.dart';
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
      final dartVersion = sdkService.dartVersion;

      final generatedFiles = await generator.generate(
        target,
        vars: <String, dynamic>{'module': module, 'dart_sdk': dartVersion},
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

      logger.success('Module "$module" created successfully');
    } catch (e) {
      logger.error('$e');
      return;
    }
  }
}
