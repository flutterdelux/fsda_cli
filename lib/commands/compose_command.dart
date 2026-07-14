import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../generators/compose_generator.dart';
import '../services/workspace_service.dart';

class ComposeCommand extends Command<void> {
  final ComposeGenerator composeGenerator;
  final WorkspaceService workspaceService;

  ComposeCommand({
    required this.composeGenerator,
    required this.workspaceService,
  }) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption('app', abbr: 'a', help: 'Target app name.')
      ..addOption('page', abbr: 'p', help: 'Target page name in snake_case.')
      ..addFlag(
        'main',
        negatable: false,
        help:
            'Mark this target page as main compose. If omitted, compose runs in inject mode.',
      );
  }

  @override
  final String name = 'compose';

  @override
  final String description =
      'Compose slice UI and logic into target app module route/page.';

  @override
  String get invocation =>
      'fsda compose <slice> -f <feature> -m <module> -a <app> -p <target_page> [--main]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing slice name.', usage);
    }
    if (args.length > 1) {
      final strayArgs = args.skip(1).join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final app = argResults?['app'] as String?;
    final targetPage = argResults?['page'] as String?;
    final isMain = argResults?['main'] as bool? ?? false;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');
    if (app == null || app.isEmpty) missingFlags.add('--app');
    if (targetPage == null || targetPage.isEmpty) missingFlags.add('--page');

    if (missingFlags.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missingFlags.join(', ')}',
        usage,
      );
    }

    final slice = args.first;

    final sliceNameRegExp = RegExp(CliRules.sliceNamePattern);
    if (!sliceNameRegExp.hasMatch(slice)) {
      throw UsageException(
        'Invalid slice name "$slice".\n'
        '${CliRules.sliceNameRule}',
        usage,
      );
    }

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature!)) {
      throw UsageException(
        'Invalid feature name "$feature".\n'
        '${CliRules.featureNameRule}',
        usage,
      );
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module!)) {
      throw UsageException(
        'Invalid module name "$module".\n'
        '${CliRules.moduleNameRule}',
        usage,
      );
    }

    final appNameRegExp = RegExp(CliRules.appNamePattern);
    if (!appNameRegExp.hasMatch(app!)) {
      throw UsageException(
        'Invalid app name "$app".\n'
        '${CliRules.appNameRule}',
        usage,
      );
    }

    final pageNameRegExp = RegExp(CliRules.pageNamePattern);
    if (!pageNameRegExp.hasMatch(targetPage!)) {
      throw UsageException(
        'Invalid target page name "$targetPage".\n'
        '${CliRules.pageNameRule}',
        usage,
      );
    }

    final moduleDir = Directory(
      p.join(Directory.current.path, 'modules', module),
    );
    if (!await moduleDir.exists()) {
      throw UsageException('Module "$module" does not exist.', usage);
    }

    final featureDir = Directory(
      p.join(moduleDir.path, 'lib', 'src', 'features', feature),
    );
    if (!await featureDir.exists()) {
      throw UsageException(
        'Feature "$feature" does not exist in module "$module".',
        usage,
      );
    }

    final appDir = Directory(
      p.join(Directory.current.path, 'apps', app, 'lib', 'modules', module),
    );
    if (!await appDir.exists()) {
      throw UsageException(
        'Module wrapper for "$module" does not exist in app "$app". Run `fsda reg $module -a $app` first.',
        usage,
      );
    }

    if (isMain) {
      await composeGenerator.composeMain((
        app: app,
        module: module,
        feature: feature,
        slice: slice,
        targetPage: targetPage,
      ));
      return;
    }

    await composeGenerator.composePmi((
      app: app,
      module: module,
      feature: feature,
      slice: slice,
      targetPage: targetPage,
    ));
  }
}
