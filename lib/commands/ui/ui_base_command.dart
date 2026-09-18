import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../enums/ui_code.dart';
import '../../generators/ui_generator.dart';
import '../../models/generation/input_typed_field.dart';
import '../../services/workspace_service.dart';

abstract class UiBaseCommand extends Command<void> {
  final UiGenerator uiGenerator;
  final WorkspaceService workspaceService;

  UiCode get uiTemplate;

  String? resolveInitialType() => null;

  List<InputTypedField> resolveFormInputFields() => const <InputTypedField>[];

  void validateTrailingArgs(List<String> trailingArgs) {
    if (trailingArgs.isEmpty) {
      return;
    }

    final strayArgs = trailingArgs.join(' ');
    throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
  }

  UiBaseCommand({required this.uiGenerator, required this.workspaceService}) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addFlag(
        'strict',
        negatable: false,
        help:
            'Fail when command would skip generation due existing files or unsafe injection targets.',
      )
      ..addFlag(
        'hook-disabled',
        negatable: false,
        help:
            'Skip post-hook execution and print manual next steps to run afterward.',
      );
  }

  @override
  String get invocation =>
      'fsda $name <slice> -f <feature> -m <module> [--strict] [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing slice name.', usage);
    }

    validateTrailingArgs(args.skip(1).toList(growable: false));

    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final strict = argResults?['strict'] as bool? ?? false;
    final hookDisabled = argResults?['hook-disabled'] as bool? ?? false;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');

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

    final formInputFields = resolveFormInputFields();
    final initialType = resolveInitialType();

    await uiGenerator.generate((
      slice: slice,
      feature: feature,
      module: module,
      ui: uiTemplate,
      operationLabel: 'fsda $name',
      formInputFields: formInputFields,
      initialType: initialType,
      strict: strict,
      hookDisabled: hookDisabled,
    ));
  }
}
