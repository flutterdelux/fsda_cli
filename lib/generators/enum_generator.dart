import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../generated/bricks/enum_bundle.dart';
import '../services/memory_generator_target.dart';
import '../services/operation_report_service.dart';
import 'base_generator.dart';

const _postHooks = ['flutter gen-l10n'];

class EnumGenerator
    extends
        BaseGenerator<
          void,
          ({
            String enumName,
            String feature,
            String module,
            List<String> values,
            bool strict,
          })
        > {
  EnumGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
  });

  @override
  Future<void> generate(
    ({
      String enumName,
      String feature,
      String module,
      List<String> values,
      bool strict,
    })
    args,
  ) async {
    final enumName = args.enumName;
    final feature = args.feature;
    final module = args.module;
    final values = args.values;
    final strict = args.strict;

    if (fileService == null) {
      logger.error('FileService is required for enum generation.');
      exitCode = 1;
      return;
    }

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
      return;
    }

    final barrelPath = p.join(featureRoot, '${feature.snakeCase}_feature.dart');
    final barrelFile = File(barrelPath);

    if (!await barrelFile.exists()) {
      logger.error(
        'Feature barrel file not found at: modules/$module/lib/src/features/$feature/${feature}_feature.dart',
      );
      exitCode = 1;
      return;
    }

    final progress = logger.progress('Baking enum "$enumName" in memory...');
    final report = OperationReportService();

    try {
      final generator = await MasonGenerator.fromBundle(enumBundle);
      final memoryTarget = MemoryGeneratorTarget();

      final enumClass = enumName.pascalCase;
      final enumLabel = _resolveEnumLabel(
        enumName: enumName,
        featureName: feature,
      );

      await generator.generate(
        memoryTarget,
        vars: <String, dynamic>{
          'module': module,
          'feature': feature,
          'enum_name': enumName,
          'enum_class': enumClass,
          'enum_values_block': _buildEnumValuesBlock(values),
          'from_json_cases': _buildFromJsonCases(
            enumClass: enumClass,
            values: values,
          ),
          'to_json_cases': _buildToJsonCases(
            enumClass: enumClass,
            values: values,
          ),
          'localize_cases': _buildLocalizeCases(
            enumClass: enumClass,
            enumName: enumName,
            values: values,
          ),
          'invalid_enum_label': enumLabel.toLowerCase(),
        },
      );

      progress.update('Writing enum artifacts to feature directory...');
      final writeResult = await fileService!.generateTemplate(
        path: featureRoot,
        files: memoryTarget.files,
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
          'Skipped ${writeResult.skippedCount} existing enum file(s) to prevent overwrite.',
        );

        if (strict || writeResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some enum files already exist.',
          );
          report.logSummary(logger, operationLabel: 'fsda gen-enum');
          exitCode = 1;
          return;
        }
      }

      progress.update('Injecting feature exports and ARB entries...');
      final barrelChanged = await _injectFeatureBarrelExports(
        path: barrelPath,
        enumName: enumName,
      );
      if (barrelChanged) {
        report.addInjected(barrelPath);
      }

      final arbEntries = _buildArbEntries(
        enumName: enumName,
        featureName: feature,
        values: values,
      );
      final touchedArbFiles = await _injectArbEntries(
        moduleName: module,
        entries: arbEntries,
      );
      for (final filePath in touchedArbFiles) {
        report.addInjected(filePath);
      }

      if (touchedArbFiles.isNotEmpty) {
        progress.update('Running post hooks...');
        await hookService!.runHook(
          hooks: _postHooks,
          workingDirectory: p.join(Directory.current.path, 'modules', module),
        );
      }

      progress.complete(
        'Enum "$enumName" successfully generated for "$feature" feature.',
      );
      report.logSummary(logger, operationLabel: 'fsda gen-enum');
    } catch (e) {
      progress.fail('Failed to generate enum "$enumName": $e');
      exitCode = 1;
    }
  }

  String _buildEnumValuesBlock(List<String> values) {
    return values.map((value) => '  $value,').join('\n');
  }

  String _buildFromJsonCases({
    required String enumClass,
    required List<String> values,
  }) {
    return values
        .map((value) => "      '${value.toUpperCase()}' => $enumClass.$value,")
        .join('\n');
  }

  String _buildToJsonCases({
    required String enumClass,
    required List<String> values,
  }) {
    return values
        .map((value) => "      $enumClass.$value => '${value.toUpperCase()}',")
        .join('\n');
  }

  String _buildLocalizeCases({
    required String enumClass,
    required String enumName,
    required List<String> values,
  }) {
    final enumCamel = enumName.camelCase;
    return values
        .map(
          (value) =>
              '      $enumClass.$value => l10n.$enumCamel${value.pascalCase},',
        )
        .join('\n');
  }

  Map<String, dynamic> _buildArbEntries({
    required String enumName,
    required String featureName,
    required List<String> values,
  }) {
    final entries = <String, dynamic>{};
    final enumCamel = enumName.camelCase;
    entries['${enumCamel}Label'] = _resolveEnumLabel(
      enumName: enumName,
      featureName: featureName,
    );

    for (final value in values) {
      entries['$enumCamel${value.pascalCase}'] = value.titleCase;
    }

    return entries;
  }

  Future<bool> _injectFeatureBarrelExports({
    required String path,
    required String enumName,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();
    var changed = false;

    final domainExport = "export 'domain/enums/${enumName.snakeCase}.dart';";
    final extensionExport =
        "export 'ui/shared/extensions/${enumName.snakeCase}_x.dart';";

    changed =
        _insertExportUnderLayer(
          lines: lines,
          existingStatements: existingStatements,
          layer: 'domain',
          statement: domainExport,
        ) ||
        changed;

    changed =
        _insertExportUnderLayer(
          lines: lines,
          existingStatements: existingStatements,
          layer: 'ui',
          statement: extensionExport,
        ) ||
        changed;

    if (!changed) {
      return false;
    }

    final normalized = _normalizeBlankLines(lines.join('\n')).trimRight();
    await file.writeAsString('$normalized\n');
    return true;
  }

  bool _insertExportUnderLayer({
    required List<String> lines,
    required Set<String> existingStatements,
    required String layer,
    required String statement,
  }) {
    if (existingStatements.contains(statement)) {
      return false;
    }

    final marker = '// $layer';
    final markerIndex = lines.indexWhere((line) => line.trim() == marker);

    if (markerIndex == -1) {
      if (lines.isNotEmpty && lines.last.trim().isNotEmpty) {
        lines.add('');
      }
      lines.add(marker);
      lines.add(statement);
      existingStatements.add(statement);
      return true;
    }

    var insertIndex = markerIndex + 1;
    while (insertIndex < lines.length) {
      final trimmed = lines[insertIndex].trim();
      if (trimmed.isEmpty) {
        insertIndex += 1;
        continue;
      }
      if (trimmed.startsWith('// ')) {
        break;
      }
      if (trimmed.startsWith('export ')) {
        insertIndex += 1;
        continue;
      }
      break;
    }

    lines.insert(insertIndex, statement);
    existingStatements.add(statement);
    return true;
  }

  Future<Set<String>> _injectArbEntries({
    required String moduleName,
    required Map<String, dynamic> entries,
  }) async {
    final touchedPaths = <String>{};
    final l10nDir = Directory(
      p.join(Directory.current.path, 'modules', moduleName, 'lib', 'l10n'),
    );

    if (!await l10nDir.exists()) {
      logger.info(
        'L10n directory not found in module "$moduleName", skipping ARB injection.',
      );
      return touchedPaths;
    }

    final arbFiles = l10nDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList();

    if (arbFiles.isEmpty) {
      logger.info(
        'No .arb files found in module "$moduleName", skipping ARB injection.',
      );
      return touchedPaths;
    }

    const encoder = JsonEncoder.withIndent('  ');
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

      await arbFile.writeAsString('${encoder.convert(arbMap)}\n');
      touchedPaths.add(arbFile.path);
      logger.success(
        'Injected $added ARB entr${added == 1 ? 'y' : 'ies'} into ${p.basename(arbFile.path)}',
      );
    }

    if (touchedPaths.isEmpty) {
      logger.info(
        'ARB entries already exist in all module .arb files for "$moduleName".',
      );
    }

    return touchedPaths;
  }

  String _resolveEnumLabel({
    required String enumName,
    required String featureName,
  }) {
    final enumTokens = enumName.snakeCase
        .split('_')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    final featureTokens = featureName.snakeCase
        .split('_')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    if (enumTokens.length > featureTokens.length && featureTokens.isNotEmpty) {
      var prefixMatches = true;
      for (var i = 0; i < featureTokens.length; i++) {
        if (enumTokens[i] != featureTokens[i]) {
          prefixMatches = false;
          break;
        }
      }

      if (prefixMatches) {
        final remaining = enumTokens.sublist(featureTokens.length);
        if (remaining.isNotEmpty) {
          return remaining.join('_').titleCase;
        }
      }
    }

    return enumName.titleCase;
  }

  String _normalizeBlankLines(String source) {
    final sanitized = source.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    return sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}
