import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../enums/ui_code.dart';
import '../generated/bricks/ui_detail_bundle.dart';
import '../generated/bricks/ui_dialog_bundle.dart';
import '../generated/bricks/ui_form_bundle.dart';
import '../generated/bricks/ui_lsh_bundle.dart';
import '../generated/bricks/ui_lsv_bundle.dart';
import '../generated/bricks/ui_pag_bundle.dart';
import '../generated/bricks/ui_pmi_bundle.dart';
import '../generated/bricks/ui_sec_bundle.dart';
import '../services/memory_generator_target.dart';
import 'base_generator.dart';

class UiGenerator
    extends
        BaseGenerator<
          void,
          ({String slice, String feature, String module, UiCode ui})
        > {
  UiGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
  });

  @override
  Future<void> generate(
    ({String slice, String feature, String module, UiCode ui}) args,
  ) async {
    final sliceName = args.slice;
    final featureName = args.feature;
    final moduleName = args.module;
    final uiCode = args.ui;

    if (fileService == null) {
      logger.error('FileService is required for weaving ui template.');
      return;
    }

    logger.info(
      'Weaving UI "$sliceName" -> "$moduleName/$featureName" as ${uiCode.description} template...',
    );

    final progress = logger.progress('Baking UI "$sliceName" in memory...');
    final memoryGeneratorTarget = MemoryGeneratorTarget();

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
      await fileService!.generateTemplate(
        path: featureRoot,
        files: standaloneFilesToSave,
      );

      progress.update('Parsing UI manifest...');
      final doc = loadYaml(uiYamlRaw) as YamlMap;
      final exportMap = doc['export'] as YamlMap?;
      final arbEntries = _readArbEntries(doc['arb']);
      final postHooks = List<String>.from(
        doc['post_hooks'] as List? ?? const [],
      );

      if (exportMap != null && exportMap.isNotEmpty) {
        progress.update('Registering UI exports to feature barrel...');
        await _updateFeatureBarrelStructured(
          path: p.join(featureRoot, '${featureName}_feature.dart'),
          exportMap: exportMap,
        );
      }

      if (arbEntries.isNotEmpty) {
        progress.update('Injecting ARB entries to all .arb files...');
        await _injectArbEntries(moduleName: moduleName, entries: arbEntries);
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
        );
      }

      progress.complete(
        'UI "$sliceName" successfully woven into "$featureName" feature! 🎨',
      );
    } catch (e) {
      progress.fail('Failed to weave UI template: $e');
    }
  }

  Future<void> _updateFeatureBarrelStructured({
    required String path,
    required YamlMap exportMap,
  }) async {
    final file = File(path);
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();

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
    }

    await file.writeAsString('${lines.join('\n')}\n');
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

  Future<void> _injectArbEntries({
    required String moduleName,
    required Map<String, dynamic> entries,
  }) async {
    final l10nDir = Directory(
      p.join(Directory.current.path, 'modules', moduleName, 'lib', 'l10n'),
    );

    if (!await l10nDir.exists()) {
      logger.info(
        'L10n directory not found in module "$moduleName", skipping arb injection.',
      );
      return;
    }

    final arbFiles = l10nDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList();

    if (arbFiles.isEmpty) {
      logger.info(
        'No .arb files found in module "$moduleName", skipping arb injection.',
      );
      return;
    }

    const encoder = JsonEncoder.withIndent('  ');
    var touchedFiles = 0;
    var totalAdded = 0;

    for (final arbFile in arbFiles) {
      final rawJson = await arbFile.readAsString();
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) {
        throw FormatException(
          'Invalid ARB format at ${arbFile.path}: expected JSON object root.',
        );
      }

      final arbMap = Map<String, dynamic>.from(decoded);
      var added = 0;

      for (final entry in entries.entries) {
        if (arbMap.containsKey(entry.key)) {
          continue;
        }

        arbMap[entry.key] = entry.value;
        added += 1;
      }

      if (added == 0) {
        continue;
      }

      touchedFiles += 1;
      totalAdded += added;
      await arbFile.writeAsString('${encoder.convert(arbMap)}\n');
      final fileName = p.basename(arbFile.path);
      logger.success(
        'Injected $added ARB entr${added == 1 ? 'y' : 'ies'} into $fileName',
      );
    }

    if (totalAdded == 0) {
      logger.info(
        'ARB entries already exist in all module .arb files for "$moduleName".',
      );
      return;
    }

    logger.success(
      'Injected total $totalAdded ARB entr${totalAdded == 1 ? 'y' : 'ies'} across $touchedFiles .arb file${touchedFiles == 1 ? '' : 's'}.',
    );
  }

  MasonBundle _resolveUiBundle(UiCode uiCode) {
    return switch (uiCode) {
      UiCode.detail => uiDetailBundle,
      UiCode.dialog => uiDialogBundle,
      UiCode.form => uiFormBundle,
      UiCode.lsh => uiLshBundle,
      UiCode.lsv => uiLsvBundle,
      UiCode.pag => uiPagBundle,
      UiCode.pmi => uiPmiBundle,
      UiCode.sec => uiSecBundle,
    };
  }
}
