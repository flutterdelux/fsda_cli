import 'dart:collection';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../enums/sequence_code.dart';
import '../enums/ui_code.dart';
import '../generators/slice_generator.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';

class GenSliceCommand extends Command<void> {
  final SliceGenerator sliceGenerator;
  final UiGenerator uiGenerator;
  final WorkspaceService workspaceService;

  GenSliceCommand({
    required this.sliceGenerator,
    required this.uiGenerator,
    required this.workspaceService,
  }) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption(
        'sequence',
        abbr: 's',
        help:
            'Sequence code. Current supported code: ${SequenceCode.values.map((e) => e.code).join(', ')}',
      )
      ..addMultiOption(
        'ui',
        abbr: 'u',
        help:
            'Optional UI code(s). Repeat -u or pass comma-separated values. Supported: ${UiCode.values.map((e) => e.code).join(', ')}',
      )
      ..addOption('method', abbr: 'd', help: 'Optional custom method name.');
  }

  @override
  final String name = 'gen-slice';

  @override
  final String description =
      'Generate a slice in a target feature and weave it into checkpoints.';

  @override
  String get invocation =>
      'fsda gen-slice <slice> -f <feature> -m <module> -s <sequence_code> [-d <method>] [-u <ui_code>]...';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isEmpty) {
      throw UsageException('Missing slice name.', usage);
    }

    final feature = argResults?['feature'] as String?;
    final module = argResults?['module'] as String?;
    final sequence = argResults?['sequence'] as String?;
    final uiValues = (argResults?['ui'] as List<String>? ?? const <String>[])
        .map((code) => code.trim())
        .where((code) => code.isNotEmpty)
        .toList(growable: true);

    final extraArgs = args.skip(1).map((value) => value.trim()).toList();
    if (extraArgs.isNotEmpty) {
      final isUiArgsOnly = extraArgs.every(
        (value) => UiCode.values.any((ui) => ui.code == value),
      );

      if (isUiArgsOnly) {
        uiValues.addAll(extraArgs);
      } else {
        final strayArgs = extraArgs.join(' ');
        throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
      }
    }

    final method = argResults?['method'] as String?;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');
    if (sequence == null || sequence.isEmpty) {
      missingFlags.add('--sequence');
    }

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

    SequenceCode sequenceCode;
    try {
      sequenceCode = SequenceCode.fromValue(sequence);
    } catch (e) {
      throw UsageException(e.toString(), usage);
    }

    final uiCodes = <UiCode>[];
    final uniqueUiValues = LinkedHashSet<String>.from(uiValues);
    for (final uiValue in uniqueUiValues) {
      try {
        uiCodes.add(UiCode.fromValue(uiValue));
      } catch (e) {
        throw UsageException(e.toString(), usage);
      }
    }

    final String resolvedMethod;
    if (method != null && method.isNotEmpty) {
      final methodNameRegExp = RegExp(CliRules.methodNamePattern);
      if (!methodNameRegExp.hasMatch(method)) {
        throw UsageException(
          'Invalid method name "$method".\n'
          '${CliRules.methodNameRule}',
          usage,
        );
      }
      resolvedMethod = method;
    } else {
      if (sequenceCode.isMutation) {
        resolvedMethod = slice.camelCase + feature.pascalCase;
      } else {
        resolvedMethod = feature.camelCase + slice.pascalCase;
      }
    }

    await sliceGenerator.generate((
      slice: slice,
      feature: feature,
      module: module,
      sequence: sequenceCode,
      method: resolvedMethod,
    ));

    for (final uiCode in uiCodes) {
      await uiGenerator.generate((
        slice: slice,
        feature: feature,
        module: module,
        ui: uiCode,
      ));
    }
  }
}
