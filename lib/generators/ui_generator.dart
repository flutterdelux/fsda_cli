import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../enums/ui_code.dart';
import '../generated/bricks/ui_action_bundle.dart';
import '../generated/bricks/ui_dialog_bundle.dart';
import '../generated/bricks/ui_form_bundle.dart';
import '../generated/bricks/ui_form_dialog_bundle.dart';
import '../generated/bricks/ui_lsh_bundle.dart';
import '../generated/bricks/ui_lsv_bundle.dart';
import '../generated/bricks/ui_main_bundle.dart';
import '../generated/bricks/ui_pag_bundle.dart';
import '../generated/bricks/ui_pmi_bundle.dart';
import '../generated/bricks/ui_sec_bundle.dart';
import '../models/generation/input_typed_field.dart';
import '../services/l10n/arb_injector_service.dart';
import '../services/memory_generator_target.dart';
import '../services/operation_report_service.dart';
import '../services/ui/ui_form_service.dart';
import 'base_generator.dart';

class UiGenerator
    extends
        BaseGenerator<
          void,
          ({
            String slice,
            String feature,
            String module,
            UiCode ui,
            String operationLabel,
            List<InputTypedField> formInputFields,
            String? initialType,
            bool strict,
            bool hookDisabled,
          })
        > {
  final ArbInjectorService arbInjectorService;
  final UiFormService uiFormService;

  UiGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
    ArbInjectorService? arbInjectorService,
    UiFormService? uiFormService,
  }) : arbInjectorService =
           arbInjectorService ?? ArbInjectorService(logger: logger),
       uiFormService = uiFormService ?? const UiFormService();

  @override
  Future<void> generate(
    ({
      String slice,
      String feature,
      String module,
      UiCode ui,
      String operationLabel,
      List<InputTypedField> formInputFields,
      String? initialType,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final sliceName = args.slice;
    final featureName = args.feature;
    final moduleName = args.module;
    final uiCode = args.ui;
    final operationLabel = args.operationLabel;
    final formInputFields = args.formInputFields;
    final initialType = args.initialType;
    final strict = args.strict;
    final hookDisabled = args.hookDisabled;

    if (fileService == null) {
      logger.error('FileService is required for weaving ui template.');
      return;
    }

    logger.info(
      'Weaving UI "$sliceName" -> "$moduleName/$featureName" as ${uiCode.description} template...',
    );

    final progress = logger.progress('Baking UI "$sliceName" in memory...');
    final memoryGeneratorTarget = MemoryGeneratorTarget();
    final report = OperationReportService();

    try {
      final generator = await MasonGenerator.fromBundle(
        _resolveUiBundle(uiCode),
      );
      await generator.generate(
        memoryGeneratorTarget,
        vars: <String, dynamic>{
          'slice': sliceName,
          'feature': featureName,
          'module': moduleName,
          'ui': uiCode.code,
        },
      );

      String? uiYamlRaw;
      final standaloneFilesToSave = <String, List<int>>{};

      for (final entry in memoryGeneratorTarget.files.entries) {
        final filePath = entry.key;
        final fileBytes = entry.value;
        final fileName = p.basename(filePath);

        if (fileName == 'ui.yaml') {
          uiYamlRaw = utf8.decode(fileBytes);
          continue;
        }

        standaloneFilesToSave[filePath] = fileBytes;
      }

      if (uiYamlRaw == null) {
        throw Exception('ui.yaml not found in generated UI files.');
      }

      if ((uiCode == UiCode.form || uiCode == UiCode.formDialog) &&
          formInputFields.isNotEmpty) {
        final dynamicFormArtifacts = await uiFormService
            .rewriteFormArtifactsByFields(
              moduleName: moduleName,
              featureName: featureName,
              sliceName: sliceName,
              fields: formInputFields,
              dialogMode: uiCode == UiCode.formDialog,
              files: standaloneFilesToSave,
              initialType: initialType,
            );
        standaloneFilesToSave
          ..clear()
          ..addAll(dynamicFormArtifacts.files);
        uiYamlRaw = dynamicFormArtifacts.uiYamlRaw;
      }

      final featureRoot = p.join(
        Directory.current.path,
        'modules',
        moduleName,
        'lib',
        'src',
        'features',
        featureName,
      );

      progress.update('Writing standalone UI files to disk...');
      final templateWriteResult = await fileService!.generateTemplate(
        path: featureRoot,
        files: standaloneFilesToSave,
        failOnExisting: strict,
      );

      report.addCreatedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: templateWriteResult.writtenFiles,
      );
      report.addSkippedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: templateWriteResult.skippedFiles,
      );

      if (templateWriteResult.skippedCount > 0) {
        logger.info(
          'Skipped ${templateWriteResult.skippedCount} existing UI file(s) to prevent overwrite.',
        );

        if (strict || templateWriteResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some UI files already exist.',
          );
          report.logSummary(logger, operationLabel: operationLabel);
          exitCode = 1;
          return;
        }
      }

      progress.update('Parsing UI manifest...');
      final doc = loadYaml(uiYamlRaw) as YamlMap;
      final exportMap = doc['export'] as YamlMap?;
      final arbEntries = _readArbEntries(doc['arb']);
      final postHooks = List<String>.from(
        doc['post_hooks'] as List? ?? const [],
      );

      if (exportMap != null && exportMap.isNotEmpty) {
        progress.update('Registering UI exports to feature barrel...');
        final featureBarrelPath = p.join(
          featureRoot,
          '${featureName}_feature.dart',
        );
        final barrelChanged = await _updateFeatureBarrelStructured(
          path: featureBarrelPath,
          exportMap: exportMap,
        );
        if (barrelChanged) {
          report.addUpdated(featureBarrelPath);
        }

        if (uiCode == UiCode.form || uiCode == UiCode.formDialog) {
          final removedPrivateFieldExports = await _removePrivateFieldExports(
            path: featureBarrelPath,
            featureName: featureName,
          );
          if (removedPrivateFieldExports) {
            report.addUpdated(featureBarrelPath);
          }
        }
      }

      if (arbEntries.isNotEmpty) {
        progress.update('Injecting ARB entries to all .arb files...');
        final touchedArbFiles = await _injectArbEntries(
          moduleName: moduleName,
          entries: arbEntries,
        );

        for (final arbFilePath in touchedArbFiles) {
          report.addInjected(arbFilePath);
        }
      }

      if (postHooks.isNotEmpty) {
        progress.update('Running post hooks...');
        await hookService!.runHook(
          hooks: postHooks,
          workingDirectory: p.join(
            Directory.current.path,
            'modules',
            moduleName,
          ),
          logger: logger,
          disabled: hookDisabled,
          operationLabel: operationLabel,
        );
      }

      progress.complete(
        'UI "$sliceName" successfully woven into "$featureName" feature! 🎨',
      );
      report.logSummary(logger, operationLabel: operationLabel);
    } catch (e) {
      progress.fail('Failed to weave UI template: $e');
      exitCode = 1;
    }
  }

  Future<bool> _updateFeatureBarrelStructured({
    required String path,
    required YamlMap exportMap,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();
    var changed = false;

    for (final layer in ['data', 'domain', 'logic', 'ui']) {
      final rawExports = exportMap[layer];
      final statements = _readExportStatements(rawExports);
      if (statements.isEmpty) continue;

      final validExports = statements
          .where((stmt) => !existingStatements.contains(stmt))
          .toList();

      if (validExports.isEmpty) continue;

      final markerIndex = lines.indexWhere((l) => l.trim() == '// $layer');

      if (markerIndex != -1) {
        lines.insertAll(markerIndex + 1, validExports);
      } else {
        lines.addAll(validExports);
      }

      existingStatements.addAll(validExports);
      changed = true;
    }

    if (!changed) {
      return false;
    }

    await file.writeAsString('${lines.join('\n')}\n');
    return true;
  }

  Future<bool> _removePrivateFieldExports({
    required String path,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final before = await file.readAsString();
    final beforeLines = before.split('\n');
    final prefix = "export 'ui/shared/widgets/${featureName.snakeCase}_";

    final filtered = beforeLines
        .where((line) {
          final normalized = line.trim();
          if (!normalized.startsWith(prefix)) {
            return true;
          }
          return !normalized.endsWith("_field.dart';");
        })
        .toList(growable: false);

    final after = '${filtered.join('\n')}\n';
    final normalizedBefore = '${before.trimRight()}\n';
    if (after == normalizedBefore) {
      return false;
    }

    await file.writeAsString(after);
    return true;
  }

  List<String> _readExportStatements(dynamic rawExports) {
    if (rawExports == null) {
      return const [];
    }

    if (rawExports is String) {
      return rawExports
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    }

    throw const FormatException(
      'Invalid export format in ui.yaml. Expected string or list.',
    );
  }

  Map<String, dynamic> _readArbEntries(dynamic rawArb) {
    if (rawArb == null) {
      return const {};
    }

    if (rawArb is String) {
      return _parseArbFragment(rawArb);
    }

    if (rawArb is YamlMap || rawArb is Map) {
      final map = <String, dynamic>{};
      final entries = rawArb is YamlMap
          ? rawArb.entries
          : (rawArb as Map<dynamic, dynamic>).entries;
      for (final entry in entries) {
        map[entry.key.toString()] = entry.value;
      }
      return map;
    }

    throw const FormatException(
      'Invalid arb format in ui.yaml. Expected string block or map.',
    );
  }

  Map<String, dynamic> _parseArbFragment(String rawArb) {
    final trimmed = rawArb.trim();
    if (trimmed.isEmpty) {
      return const {};
    }

    final fragment = trimmed.replaceFirst(RegExp(r',\s*$'), '');
    final candidate = '{\n$fragment\n}';

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is! Map) {
        throw const FormatException('ARB fragment must decode to JSON object.');
      }
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      throw FormatException(
        'Invalid arb block in ui.yaml. Expected JSON key/value fragment, e.g. ""key": "value"". Error: $e',
      );
    }
  }

  Future<Set<String>> _injectArbEntries({
    required String moduleName,
    required Map<String, dynamic> entries,
  }) async {
    return arbInjectorService.injectEntries(
      moduleName: moduleName,
      entries: entries,
      contextLabel: 'fsda ui generation',
    );
  }

  MasonBundle _resolveUiBundle(UiCode uiCode) {
    return switch (uiCode) {
      UiCode.main => uiMainBundle,
      UiCode.dialog => uiDialogBundle,
      UiCode.form => uiFormBundle,
      UiCode.formDialog => uiFormDialogBundle,
      UiCode.lsh => uiLshBundle,
      UiCode.lsv => uiLsvBundle,
      UiCode.pag => uiPagBundle,
      UiCode.pmi => uiPmiBundle,
      UiCode.action => uiActionBundle,
      UiCode.sec => uiSecBundle,
    };
  }
}
