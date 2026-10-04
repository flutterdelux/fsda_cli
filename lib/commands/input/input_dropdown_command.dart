import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../generators/input/input_generator.dart';
import '../../models/generation/typed_prop.dart';
import '../../services/workspace_service.dart';

class InputDropdownCommand extends Command<void> {
  final InputGenerator inputGenerator;
  final WorkspaceService workspaceService;

  InputDropdownCommand({
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
        help:
            'Required dropdown value type. Accepts Dart type (for example String, ProductCategoryEntity) or snake_case alias (for example product_category_entity).',
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
  final String name = 'input-dropdown';

  @override
  final String description =
      'Generate shared dropdown field widget and inject ARB keys.';

  @override
  String get invocation =>
      'fsda input-dropdown <field> -f <feature> -m <module> --type <value_type> [--strict] [--hook-disabled]';

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
    final valueType = _resolveValueType();

    await inputGenerator.generateDropdown((
      feature: feature,
      module: module,
      fields: <TypedProp>[TypedProp(type: valueType, name: field)],
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
        'Invalid field token "$resolved". Use field_name syntax (for example category).',
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

  String _resolveValueType() {
    final rawType = (argResults?['type'] as String?)?.trim() ?? '';
    if (rawType.isEmpty) {
      throw UsageException('Missing required option(s): --type', usage);
    }

    final normalized = rawType.replaceAll(' ', '');
    if (normalized.contains('?')) {
      throw UsageException(
        'Invalid dropdown type "$rawType". Nullable marker (?) is not allowed for --type.',
        usage,
      );
    }

    if (normalized.startsWith('List<')) {
      throw UsageException(
        'Invalid dropdown type "$rawType". Use item type without List wrapper.',
        usage,
      );
    }

    final snakeTypeRegExp = RegExp(CliRules.sliceNamePattern);
    if (snakeTypeRegExp.hasMatch(normalized)) {
      return _resolveSnakeCaseType(normalized);
    }

    final typeRegExp = RegExp(CliRules.modelPrefixPattern);
    if (!typeRegExp.hasMatch(normalized) && !_isPrimitiveDartType(normalized)) {
      throw UsageException(
        'Invalid dropdown type "$rawType". Use a Dart type (for example String, ProductCategoryEntity) or snake_case alias (for example product_category_entity).',
        usage,
      );
    }

    return normalized;
  }

  String _resolveSnakeCaseType(String rawType) {
    switch (rawType) {
      case 'string':
        return 'String';
      case 'int':
      case 'double':
      case 'num':
      case 'bool':
      case 'dynamic':
        return rawType;
      case 'object':
        return 'Object';
      case 'date_time':
        return 'DateTime';
      case 'duration':
        return 'Duration';
      case 'big_int':
        return 'BigInt';
      case 'network_file':
        return 'NetworkFile';
      default:
        if (rawType.endsWith('_entity')) {
          final prefix = rawType.substring(
            0,
            rawType.length - '_entity'.length,
          );
          return '${prefix.pascalCase}Entity';
        }
        if (rawType.endsWith('_dto')) {
          final prefix = rawType.substring(0, rawType.length - '_dto'.length);
          return '${prefix.pascalCase}Dto';
        }
        return rawType.pascalCase;
    }
  }

  bool _isPrimitiveDartType(String type) {
    const primitiveTypes = <String>{
      'String',
      'int',
      'double',
      'num',
      'bool',
      'dynamic',
      'Object',
      'DateTime',
      'Duration',
      'BigInt',
      'NetworkFile',
    };
    return primitiveTypes.contains(type);
  }
}
