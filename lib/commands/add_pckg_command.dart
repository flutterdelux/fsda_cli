import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../generated/package_bundle.dart';
import '../generators/package_generator.dart';
import '../services/logger_service.dart';
import '../services/workspace_service.dart';

class AddPckgCommand extends Command {
  final LoggerService logger;
  final WorkspaceService workspaceService;
  final PackageGenerator packageGenerator;

  AddPckgCommand({
    required this.workspaceService,
    required this.packageGenerator,
    required this.logger,
  });

  @override
  final String name = 'add-pckg';

  @override
  final String description =
      'Add one package template to workspace/packages and sync fsda.yaml.';

  @override
  String get invocation => 'fsda add-pckg <name>';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;

    if (args.length != 1) {
      throw UsageException('Usage: fsda add-pckg <name>', usage);
    }

    final packageName = args.first.trim();
    if (packageName.isEmpty) {
      throw UsageException('Package name is required.', usage);
    }

    final nameRegExp = RegExp(CliRules.packageNamePattern);
    if (!nameRegExp.hasMatch(packageName)) {
      throw UsageException(
        'Invalid name "$packageName".\n'
        '${CliRules.packageNameRule}',
        usage,
      );
    }

    if (!packageBundle.containsKey(packageName)) {
      throw UsageException(
        'Package template "$packageName" not found. Use "fsda list-pckg" to see available templates.',
        usage,
      );
    }

    final syncResult = await _syncPackageInFsdaYaml(packageName);
    switch (syncResult) {
      case _FsdaPackageSyncResult.alreadyActive:
        logger.info(
          'fsda.yaml already contains active package "$packageName".',
        );
        break;
      case _FsdaPackageSyncResult.activatedFromComment:
        logger.info('Activated package "$packageName" in fsda.yaml.');
        break;
      case _FsdaPackageSyncResult.appended:
        logger.info('Added package "$packageName" to fsda.yaml.');
        break;
    }

    final packageDir = Directory(
      p.join(Directory.current.path, 'packages', packageName),
    );
    if (await packageDir.exists()) {
      logger.info(
        'Package "$packageName" already exists in workspace/packages. Skipping generation.',
      );
      return;
    }

    final generated = await packageGenerator.generate(packageName);
    if (!generated) {
      throw UsageException(
        'Failed to generate package "$packageName". Check logs above.',
        usage,
      );
    }

    logger.success('add-pckg completed for "$packageName".');
  }

  Future<_FsdaPackageSyncResult> _syncPackageInFsdaYaml(
    String packageName,
  ) async {
    final configFile = File('fsda.yaml');
    if (!await configFile.exists()) {
      throw UsageException('fsda.yaml not found in current workspace.', usage);
    }

    final content = await configFile.readAsString();
    final lines = content.split('\n');

    final packagesIndex = lines.indexWhere(
      (line) => RegExp(r'^\s*packages\s*:\s*$').hasMatch(line),
    );

    if (packagesIndex == -1) {
      throw UsageException(
        'Format fsda.yaml invalid: key "packages:" not found.',
        usage,
      );
    }

    var sectionEnd = lines.length;
    for (var i = packagesIndex + 1; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final isTopLevel = !line.startsWith(' ') && !line.startsWith('\t');
      if (isTopLevel) {
        sectionEnd = i;
        break;
      }
    }

    final activePattern = RegExp(
      r'^\s*-\s*' + RegExp.escape(packageName) + r'(?:\s+#.*)?\s*$',
    );
    final commentedPattern = RegExp(
      r'^\s*#\s*-\s*' + RegExp.escape(packageName) + r'(?:\s+#.*)?\s*$',
    );

    for (var i = packagesIndex + 1; i < sectionEnd; i++) {
      if (activePattern.hasMatch(lines[i])) {
        return _FsdaPackageSyncResult.alreadyActive;
      }
    }

    for (var i = packagesIndex + 1; i < sectionEnd; i++) {
      if (commentedPattern.hasMatch(lines[i])) {
        final indentMatch = RegExp(r'^(\s*)#').firstMatch(lines[i]);
        final indent = indentMatch?.group(1) ?? '  ';
        lines[i] = '$indent- $packageName';
        await configFile.writeAsString(lines.join('\n'));
        return _FsdaPackageSyncResult.activatedFromComment;
      }
    }

    lines.insert(sectionEnd, '  - $packageName');
    await configFile.writeAsString(lines.join('\n'));
    return _FsdaPackageSyncResult.appended;
  }
}

enum _FsdaPackageSyncResult { alreadyActive, activatedFromComment, appended }
