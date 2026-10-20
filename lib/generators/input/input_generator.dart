import 'dart:io';

import 'package:path/path.dart' as p;

import '../../enums/input_code.dart';
import '../../models/generation/typed_prop.dart';
import '../../services/command_operation_service.dart';
import '../../services/file_service.dart';
import '../../services/l10n/arb_injector_service.dart';
import '../../services/logger_service.dart';
import '../../services/operation_report_service.dart';
import 'services/input_arb_entry_builder_service.dart';
import 'services/input_widget_file_builder_service.dart';

const _inputPostHooks = ['flutter gen-l10n'];

class InputGenerator {
  final ArbInjectorService arbInjectorService;
  final InputWidgetFileBuilderService widgetFileBuilderService;
  final InputArbEntryBuilderService arbEntryBuilderService;
  final FileService fileService;
  final OperationReportService report;
  final LoggerService logger;
  final CommandOperationService commandOperationService;

  InputGenerator({
    required this.arbInjectorService,
    required this.widgetFileBuilderService,
    required this.arbEntryBuilderService,
    required this.fileService,
    required this.report,
    required this.logger,
    required this.commandOperationService,
  });

  Future<Map<String, dynamic>> generate(
    ({
      String feature,
      String module,
      List<String> fields,
      InputCode input,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final feature = args.feature;
    final module = args.module;
    final fields = args.fields;
    final input = args.input;
    final strict = args.strict;
    final hookDisabled = args.hookDisabled;

    if (input != InputCode.text && input != InputCode.password) {
      logger.error(
        'InputGenerator.generate only supports text/password mode. Use dedicated dropdown generator methods.',
      );
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }

    if (input == InputCode.text) {
      final typedFields = fields
          .map((field) => TypedProp(type: 'String', name: field))
          .toList(growable: false);

      return generateTextTyped((
        feature: feature,
        module: module,
        fields: typedFields,
        strict: strict,
        hookDisabled: hookDisabled,
      ));
    }

    final files = widgetFileBuilderService.buildCodeDrivenFiles(
      featureName: feature,
      moduleName: module,
      fields: fields,
      inputCode: input,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: feature,
      fields: fields,
      inputCode: input,
    );

    return _generateInputArtifacts(
      feature: feature,
      module: module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-${input.code}',
      progressLabel:
          'Baking ${input.description.toLowerCase()} widget(s) in memory...',
      successLabel:
          '${input.description} widget(s) successfully generated for "$feature" feature.',
      strict: strict,
      hookDisabled: hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateTextTyped(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildTextTypedFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields.map((field) => field.name).toList(growable: false),
      inputCode: InputCode.text,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-text',
      progressLabel: 'Baking text field widget(s) in memory...',
      successLabel:
          'Text field widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateNumberTyped(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildTextTypedFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields.map((field) => field.name).toList(growable: false),
      inputCode: InputCode.text,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-number',
      progressLabel: 'Baking number field widget(s) in memory...',
      successLabel:
          'Number field widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateTextAreaTyped(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      int minLines,
      int maxLines,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildTextAreaTypedFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
      minLines: args.minLines,
      maxLines: args.maxLines,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields.map((field) => field.name).toList(growable: false),
      inputCode: InputCode.text,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-text-area',
      progressLabel: 'Baking text area widget(s) in memory...',
      successLabel:
          'Text area widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateQty(
    ({
      String feature,
      String module,
      List<String> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildTextQtyFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields,
      inputCode: InputCode.text,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-qty',
      progressLabel: 'Baking quantity field widget(s) in memory...',
      successLabel:
          'Quantity field widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateDropdownEnum(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildDropdownEnumFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEnumDropdownEntries(
      featureName: args.feature,
      fields: args.fields,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-dropdown-enum',
      progressLabel: 'Baking dropdown enum widget(s) in memory...',
      successLabel:
          'Dropdown enum widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateDropdown(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildDropdownFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildDropdownEntries(
      featureName: args.feature,
      fields: args.fields,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-dropdown',
      progressLabel: 'Baking dropdown widget(s) in memory...',
      successLabel:
          'Dropdown widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateSelector(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildSelectorFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields.map((field) => field.name).toList(growable: false),
      inputCode: InputCode.dropdown,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-selector',
      progressLabel: 'Baking selector input widget(s) in memory...',
      successLabel:
          'Selector input widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateSelectorList(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildSelectorListFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields.map((field) => field.name).toList(growable: false),
      inputCode: InputCode.dropdown,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-selector-list',
      progressLabel: 'Baking selector-list input widget(s) in memory...',
      successLabel:
          'Selector-list input widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateImage(
    ({
      String feature,
      String module,
      List<TypedProp> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildImageFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildEntriesByInputCode(
      featureName: args.feature,
      fields: args.fields.map((field) => field.name).toList(growable: false),
      inputCode: InputCode.dropdown,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-image',
      progressLabel: 'Baking image input widget(s) in memory...',
      successLabel:
          'Image input widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> generateSwitch(
    ({
      String feature,
      String module,
      List<String> fields,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final files = widgetFileBuilderService.buildSwitchFiles(
      featureName: args.feature,
      moduleName: args.module,
      fields: args.fields,
    );

    final arbEntries = arbEntryBuilderService.buildSwitchEntries(
      featureName: args.feature,
      fields: args.fields,
    );

    return _generateInputArtifacts(
      feature: args.feature,
      module: args.module,
      files: files,
      arbEntries: arbEntries,
      operationLabel: 'fsda input-switch',
      progressLabel: 'Baking switch input widget(s) in memory...',
      successLabel:
          'Switch input widget(s) successfully generated for "${args.feature}" feature.',
      strict: args.strict,
      hookDisabled: args.hookDisabled,
    );
  }

  Future<Map<String, dynamic>> _generateInputArtifacts({
    required String feature,
    required String module,
    required Map<String, List<int>> files,
    required Map<String, dynamic> arbEntries,
    required String operationLabel,
    required String progressLabel,
    required String successLabel,
    required bool strict,
    required bool hookDisabled,
  }) async {
    return commandOperationService.run<Map<String, dynamic>>(
      operationLabel: operationLabel,
      hookDisabled: hookDisabled,
      action: () async {
        final featureRoot = p.join(
          Directory.current.path,
          'modules',
          module,
          'lib',
          'src',
          'features',
          feature,
        );

        final featureDir = Directory(featureRoot);
        if (!await featureDir.exists()) {
          logger.error(
            'Feature path not found: modules/$module/lib/src/features/$feature',
          );
          exitCode = 1;
          return <String, dynamic>{'success': false};
        }

        final progress = logger.progress(progressLabel);
        var progressCompleted = false;

        try {
          final writeResult = await fileService.generateTemplate(
            path: featureRoot,
            files: files,
            failOnExisting: strict,
          );

          report.addCreatedTemplateFiles(
            targetRoot: featureRoot,
            relativeFiles: writeResult.writtenFiles,
          );
          report.addSkippedTemplateFiles(
            targetRoot: featureRoot,
            relativeFiles: writeResult.skippedFiles,
          );

          if (writeResult.skippedCount > 0) {
            logger.info(
              'Skipped ${writeResult.skippedCount} existing input widget file(s) to prevent overwrite.',
            );

            if (strict || writeResult.abortedDueToExisting) {
              logger.error(
                'Strict mode: generation aborted because some input widget files already exist.',
              );
              progress.fail('Input generation aborted by strict mode.');
              exitCode = 1;
              return <String, dynamic>{'success': false};
            }
          }

          progress.complete('Input widget artifacts prepared.');
          progressCompleted = true;

          final touchedArbFiles = await _injectArbEntries(
            moduleName: module,
            entries: arbEntries,
            contextLabel: operationLabel,
          );
          for (final filePath in touchedArbFiles) {
            report.addInjected(filePath);
          }

          logger.success(successLabel);
          return <String, dynamic>{
            'success': true,
            if (touchedArbFiles.isNotEmpty) 'post_hook': _inputPostHooks,
            'working_directory': p.join(
              Directory.current.path,
              'modules',
              module,
            ),
          };
        } catch (e) {
          if (!progressCompleted) {
            progress.fail('Failed to generate input widget(s): $e');
          } else {
            logger.error('Failed to generate input widget(s): $e');
          }
          exitCode = 1;
          return <String, dynamic>{'success': false};
        }
      },
      hookResults: (result) => [result],
    );
  }

  Future<Set<String>> _injectArbEntries({
    required String moduleName,
    required Map<String, dynamic> entries,
    required String contextLabel,
  }) async {
    return arbInjectorService.injectEntries(
      moduleName: moduleName,
      entries: entries,
      contextLabel: contextLabel,
    );
  }
}
