import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../constants/cli_rules.dart';
import '../../enums/ui_code.dart';
import '../../generators/ui_generator.dart';
import '../../models/generation/input_typed_field.dart';
import '../../services/command_operation_service.dart';
import '../../services/workspace_service.dart';

abstract class UiBaseCommand extends Command<void> {
  final UiGenerator uiGenerator;
  final WorkspaceService workspaceService;
  final CommandOperationService operations;

  UiCode get uiTemplate;

  String resolveFormDataType() => '';

  bool get initializeFormData => false;

  List<InputTypedField> resolveFormInputFields() => const <InputTypedField>[];

  void validateTrailingArgs(List<String> trailingArgs) {
    if (trailingArgs.isEmpty) {
      return;
    }

    final strayArgs = trailingArgs.join(' ');
    throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
  }

  UiBaseCommand({
    required this.uiGenerator,
    required this.workspaceService,
    required this.operations,
  }) {
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

    if (usesEntityObject) {
      argParser
        ..addOption(
          'entity',
          help:
              'Full snake_case Entity artifact name (for example payment_entity).',
        )
        ..addOption(
          'object',
          help: 'Snake_case item variable name (for example payment_method).',
        );
    }
  }

  @override
  String get invocation {
    final entityObjectOptions = usesEntityObject
        ? ' --entity <entity> --object <object>'
        : '';
    return 'fsda $name <slice> -f <feature> -m <module>$entityObjectOptions [--strict] [--hook-disabled]';
  }

  bool get usesEntityObject =>
      uiTemplate == UiCode.lsh ||
      uiTemplate == UiCode.lsv ||
      uiTemplate == UiCode.pag;

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
    final entity = usesEntityObject ? (argResults?['entity'] as String?) : null;
    final object = usesEntityObject ? (argResults?['object'] as String?) : null;

    final missingFlags = <String>[];
    if (feature == null || feature.isEmpty) missingFlags.add('--feature');
    if (module == null || module.isEmpty) missingFlags.add('--module');
    if (usesEntityObject && (entity == null || entity.isEmpty)) {
      missingFlags.add('--entity');
    }
    if (usesEntityObject && (object == null || object.isEmpty)) {
      missingFlags.add('--object');
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

    if (usesEntityObject) {
      final entityNamePattern = RegExp(CliRules.artifactNamePattern);
      if (!entityNamePattern.hasMatch(entity!) || !entity.endsWith('_entity')) {
        throw UsageException(
          'Invalid Entity name "$entity". It must be a full snake_case artifact name ending in _entity.\n${CliRules.artifactNameRule}',
          usage,
        );
      }

      final objectNamePattern = RegExp(CliRules.sliceNamePattern);
      if (!objectNamePattern.hasMatch(object!)) {
        throw UsageException(
          'Invalid object name "$object". Use a snake_case identifier that starts with a lowercase letter and contains only lowercase letters, digits, and underscores.',
          usage,
        );
      }
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

    if (usesEntityObject) {
      final entityFile = File(
        p.join(featureDir.path, 'domain', 'entities', '$entity.dart'),
      );
      if (!await entityFile.exists()) {
        throw UsageException(
          'Entity "$entity" does not exist in "$feature" feature. Expected file: domain/entities/$entity.dart. Run fsda entity first.',
          usage,
        );
      }
    }

    final formInputFields = resolveFormInputFields();
    final formDataType = resolveFormDataType();
    final initializeFormData = this.initializeFormData;

    await operations.run(
      operationLabel: 'fsda $name -> $module/$feature/$slice',
      hookDisabled: hookDisabled,
      action: () => uiGenerator.generate((
        slice: slice,
        feature: feature,
        module: module,
        ui: uiTemplate,
        operationLabel: 'fsda $name -> $module/$feature/$slice',
        formInputFields: formInputFields,
        dataType: formDataType,
        initializeFormData: initializeFormData,
        entity: entity,
        object: object,
        strict: strict,
        hookDisabled: hookDisabled,
      )),
      hookResults: (result) => [result],
    );
  }
}
