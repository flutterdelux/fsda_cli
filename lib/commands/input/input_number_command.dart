import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/input/input_generator.dart';
import '../../models/generation/typed_prop.dart';
import '../../services/workspace_service.dart';

class InputNumberCommand extends Command<void> {
  final InputGenerator inputGenerator;
  final WorkspaceService workspaceService;

  InputNumberCommand({
    required this.inputGenerator,
    required this.workspaceService,
  }) {
    argParser
      ..addOption('feature', abbr: 'f', help: 'Target feature name.')
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption(
        'field',
        help:
            'Single field name in snake_case. Alternative to positional <field>.',
      )
      ..addOption(
        'type',
        defaultsTo: 'double',
        help:
            'Numeric value type. Supported: int, double, num, BigInt. Defaults to double.',
      )
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
  final String name = 'input-number';

  @override
  final String description =
      'Generate shared numeric text field widget and inject ARB label/hint/invalid keys.';

  @override
  String get invocation =>
      'fsda input-number <field> -f <feature> -m <module> [--type <numeric_type>] [--strict] [--hook-disabled]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

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

    final featureNameRegExp = RegExp(CliRules.featureNamePattern);
    if (!featureNameRegExp.hasMatch(feature!)) {
      throw UsageException(
        'Invalid feature name "$feature".\n${CliRules.featureNameRule}',
        usage,
      );
    }

    final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
    if (!moduleNameRegExp.hasMatch(module!)) {
      throw UsageException(
        'Invalid module name "$module".\n${CliRules.moduleNameRule}',
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

    final field = _resolveField();
    final numberType = _resolveNumberType();

    await inputGenerator.generateNumberTyped((
      feature: feature,
      module: module,
      fields: <TypedProp>[TypedProp(type: numberType, name: field)],
      strict: strict,
      hookDisabled: hookDisabled,
    ));
  }

  String _resolveField() {
    final fieldFromOption = (argResults?['field'] as String?)?.trim() ?? '';
    final trailingValues = argResults!.rest
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (fieldFromOption.isNotEmpty && trailingValues.isNotEmpty) {
      throw UsageException(
        'Provide field either as positional <field> or --field, not both.',
        usage,
      );
    }

    if (trailingValues.length > 1) {
      throw UsageException(
        'Unexpected argument(s): "${trailingValues.skip(1).join(' ')}".',
        usage,
      );
    }

    final resolved = trailingValues.isNotEmpty
        ? trailingValues.first
        : fieldFromOption;
    if (resolved.isEmpty) {
      throw UsageException('Missing required argument: <field>', usage);
    }

    if (resolved.contains(':') || resolved.contains('=')) {
      throw UsageException(
        'Invalid field token "$resolved". Use field_name syntax (for example amount).',
        usage,
      );
    }

    final fieldNameRegExp = RegExp(CliRules.sliceNamePattern);
    if (!fieldNameRegExp.hasMatch(resolved)) {
      throw UsageException(
        'Invalid field name "$resolved".\n${CliRules.sliceNameRule}',
        usage,
      );
    }

    return resolved;
  }

  String _resolveNumberType() {
    final rawType = (argResults?['type'] as String?)?.trim() ?? 'double';
    final normalized = rawType.replaceAll(' ', '');
    const supportedTypes = <String>{'int', 'double', 'num', 'BigInt'};

    if (!supportedTypes.contains(normalized)) {
      throw UsageException(
        'Invalid numeric type "$rawType". Supported values: int, double, num, BigInt.',
        usage,
      );
    }

    return normalized;
  }
}
