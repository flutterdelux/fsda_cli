import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../constants/cli_info.dart';
import '../enums/sequence_code.dart';
import '../generated/bricks/sequence_m_bundle.dart';
import '../generated/bricks/sequence_mp_bundle.dart';
import '../generated/bricks/sequence_mr_bundle.dart';
import '../generated/bricks/sequence_mrp_bundle.dart';
import '../generated/bricks/sequence_r_bundle.dart';
import '../generated/bricks/sequence_rof_bundle.dart';
import '../generated/bricks/sequence_rp_bundle.dart';
import '../generated/bricks/sequence_rpag_bundle.dart';
import '../generated/bricks/sequence_rs_bundle.dart';
import '../generated/bricks/sequence_rsp_bundle.dart';
import '../services/memory_generator_target.dart';
import '../services/operation_report_service.dart';
import 'base_generator.dart';

typedef _SequenceSection = ({String imports, String code});

class SliceGenerator
    extends
        BaseGenerator<
          void,
          ({
            String slice,
            String feature,
            String module,
            SequenceCode sequence,
            String method,
            bool strict,
          })
        > {
  SliceGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
  });

  @override
  Future<void> generate(
    ({
      String slice,
      String feature,
      String module,
      SequenceCode sequence,
      String method,
      bool strict,
    })
    args,
  ) async {
    final sliceName = args.slice;
    final featureName = args.feature;
    final moduleName = args.module;
    final sequence = args.sequence;
    final methodName = args.method;
    final strict = args.strict;

    final isMutation = sequence.isMutation;

    if (fileService == null) {
      logger.error('FileService is required for weaving code.');
      return;
    }

    logger.info(
      'Weaving slice "$sliceName" -> "$moduleName/$featureName" as ${sequence.description} sequence...',
    );
    final progress = logger.progress('Baking slice "$sliceName" in memory...');
    final memoryGeneratorTarget = MemoryGeneratorTarget();
    final report = OperationReportService();

    try {
      final generator = await MasonGenerator.fromBundle(
        _resolveSequenceBundle(sequence),
      );
      await generator.generate(
        memoryGeneratorTarget,
        vars: <String, dynamic>{
          'slice': sliceName,
          'feature': featureName,
          'module': moduleName,
          'sequence': sequence.code,
          'method': methodName,
        },
      );

      String? sequenceYamlRaw;
      final standaloneFilesToSave = <String, List<int>>{};

      for (final entry in memoryGeneratorTarget.files.entries) {
        final filePath = entry.key;
        final fileBytes = entry.value;
        final fileName = p.basename(filePath);

        if (fileName == 'sequence.yaml') {
          sequenceYamlRaw = utf8.decode(fileBytes);
          continue;
        }

        standaloneFilesToSave[filePath] = fileBytes;
      }

      if (sequenceYamlRaw == null) {
        throw Exception(
          'sequence.yaml not found in the generated slice files.',
        );
      }

      final featureRoot = p.join(
        Directory.current.path,
        'modules',
        args.module,
        'lib',
        'src',
        'features',
        args.feature,
      );

      progress.update('Writing standalone slice files to disk...');
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
          'Skipped ${templateWriteResult.skippedCount} existing slice file(s) to prevent overwrite.',
        );

        if (strict || templateWriteResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some slice files already exist.',
          );
          report.logSummary(logger, operationLabel: 'fsda gen-slice');
          exitCode = 1;
          return;
        }
      }

      progress.update('Parsing sequence manifest & weaving checkpoint...');
      final doc = loadYaml(sequenceYamlRaw) as YamlMap;

      final remoteDsContract = _readSection(
        manifest: doc,
        key: 'remote_data_source_contract',
      );
      final remoteDsImpl = _readSection(
        manifest: doc,
        key: 'remote_data_source_impl',
      );
      final localDsContract = _readSection(
        manifest: doc,
        key: 'local_data_source_contract',
      );
      final localDsImpl = _readSection(
        manifest: doc,
        key: 'local_data_source_impl',
      );
      final repoContract = _readSection(
        manifest: doc,
        key: 'repository_contract',
      );
      final repoImpl = _readSection(manifest: doc, key: 'repository_impl');
      final exportMap = doc['export'] as YamlMap?;
      final postHooks = List<String>.from(doc['post_hooks'] as List? ?? []);

      final remoteContractPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${args.feature}_remote_data_source.dart',
      );
      final remoteContractChanged = await _injectDataSourceSection(
        section: remoteDsContract,
        sectionName: 'remote_data_source_contract',
        path: remoteContractPath,
        isMutation: isMutation,
        strict: strict,
      );
      if (remoteContractChanged) {
        report.addInjected(remoteContractPath);
      }

      final remoteImplPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${args.feature}_remote_data_source_impl.dart',
      );
      final remoteImplChanged = await _injectDataSourceSection(
        section: remoteDsImpl,
        sectionName: 'remote_data_source_impl',
        path: remoteImplPath,
        isMutation: isMutation,
        strict: strict,
      );
      if (remoteImplChanged) {
        report.addInjected(remoteImplPath);
      }

      final localContractPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${args.feature}_local_data_source.dart',
      );
      final localContractChanged = await _injectDataSourceSection(
        section: localDsContract,
        sectionName: 'local_data_source_contract',
        path: localContractPath,
        isMutation: isMutation,
        strict: strict,
      );
      if (localContractChanged) {
        report.addInjected(localContractPath);
      }

      final localImplPath = p.join(
        featureRoot,
        'data',
        'datasources',
        '${args.feature}_local_data_source_impl.dart',
      );
      final localImplChanged = await _injectDataSourceSection(
        section: localDsImpl,
        sectionName: 'local_data_source_impl',
        path: localImplPath,
        isMutation: isMutation,
        strict: strict,
      );
      if (localImplChanged) {
        report.addInjected(localImplPath);
      }

      final repoContractPath = p.join(
        featureRoot,
        'domain',
        'repositories',
        '${args.feature}_repository.dart',
      );
      final repoContractImportChanged = await _injectImports(
        path: repoContractPath,
        imports: repoContract.imports,
      );
      final repoContractCodeChanged = await _injectCode(
        path: repoContractPath,
        code: repoContract.code,
        isMutation: isMutation,
        strict: strict,
      );
      if (repoContractImportChanged || repoContractCodeChanged) {
        report.addInjected(repoContractPath);
      }

      final repoImplPath = p.join(
        featureRoot,
        'data',
        'repositories',
        '${args.feature}_repository_impl.dart',
      );
      final repoImplImportChanged = await _injectImports(
        path: repoImplPath,
        imports: repoImpl.imports,
      );
      final repoImplCodeChanged = await _injectCode(
        path: repoImplPath,
        code: repoImpl.code,
        isMutation: isMutation,
        strict: strict,
      );
      if (repoImplImportChanged || repoImplCodeChanged) {
        report.addInjected(repoImplPath);
      }

      if (exportMap != null && exportMap.isNotEmpty) {
        progress.update('Registering export to feature barrel...');
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
        'Slice "$sliceName" successfully woven into "$featureName" feature! 🧵✨',
      );
      report.logSummary(logger, operationLabel: 'fsda gen-slice');
    } catch (e) {
      progress.fail('Failed to stitch slice: $e');
      exitCode = 1;
    }
  }

  _SequenceSection _readSection({
    required YamlMap manifest,
    required String key,
  }) {
    final raw = manifest[key];
    if (raw == null) {
      return (imports: '', code: '');
    }

    if (raw is String) {
      return (imports: '', code: raw);
    }

    if (raw is YamlMap) {
      return (
        imports: raw['import']?.toString() ?? '',
        code: raw['code']?.toString() ?? '',
      );
    }

    throw FormatException(
      'Invalid "$key" format in sequence.yaml. Expected string or map with import/code.',
    );
  }

  Future<bool> _injectDataSourceSection({
    required _SequenceSection section,
    required String path,
    required String sectionName,
    required bool isMutation,
    required bool strict,
  }) async {
    if (section.imports.trim().isEmpty && section.code.trim().isEmpty) {
      return false;
    }

    if (!await File(path).exists()) {
      throw Exception(
        'Target file for "$sectionName" not found: $path. Regenerate baseline files for this feature, then rerun gen-slice.',
      );
    }

    final importsChanged = await _injectImports(
      path: path,
      imports: section.imports,
    );
    final codeChanged = await _injectCode(
      path: path,
      code: section.code,
      isMutation: isMutation,
      strict: strict,
    );
    return importsChanged || codeChanged;
  }

  Future<bool> _injectImports({
    required String path,
    required String imports,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final importLines = imports
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.startsWith('import '))
        .toList();

    if (importLines.isEmpty) {
      return false;
    }

    String content = await file.readAsString();
    final lines = content.split('\n');

    final existingImports = lines.map((line) => line.trim()).toSet();
    final missingImports = importLines
        .where((line) => !existingImports.contains(line))
        .toList();

    if (missingImports.isEmpty) {
      return false;
    }

    final lastImportIndex = lines.lastIndexWhere(
      (line) => line.trim().startsWith('import '),
    );

    if (lastImportIndex != -1) {
      lines.insertAll(lastImportIndex + 1, missingImports);
    } else {
      lines.insertAll(0, missingImports);
      if (lines.length > missingImports.length &&
          lines[missingImports.length].trim().isNotEmpty) {
        lines.insert(missingImports.length, '');
      }
    }

    content = '${_normalizeBlankLines(lines.join('\n')).trimRight()}\n';
    await file.writeAsString(content);
    return true;
  }

  Future<bool> _injectCode({
    required String path,
    required String code,
    required bool isMutation,
    required bool strict,
  }) async {
    if (code.trim().isEmpty) return false;

    final file = File(path);
    if (!await file.exists()) return false;

    String content = await file.readAsString();

    final declarationLine = _extractDeclarationLine(code);
    if (declarationLine != null &&
        _containsLineLike(content, declarationLine)) {
      logger.info(
        'Skipping code injection in $path because declaration already exists.',
      );
      return false;
    }

    if (_containsSnippet(content, code)) {
      logger.info(
        'Skipping code injection in $path because snippet already exists.',
      );
      return false;
    }

    final targetCheckpoint = isMutation
        ? CliInfo.mutationCheckpoint
        : CliInfo.retrievalCheckpoint;

    final formattedCode = code.trimRight().split('\n').join('\n  ');

    if (content.contains(targetCheckpoint)) {
      // Scenario A: Checkpoint comment exists, insert code below it!
      content = content.replaceFirst(
        targetCheckpoint,
        '$targetCheckpoint\n\n  $formattedCode',
      );
    } else {
      // Scenario B: Checkpoint comment missing (removed by user)
      if (strict) {
        throw Exception(
          'Strict mode: checkpoint "$targetCheckpoint" not found in $path. Refusing fallback injection before class closing brace.',
        );
      }

      final closingOffset = _findClassClosingBraceAST(content);

      if (closingOffset == -1) {
        logger.error(
          'Failed to find class closing brace in $path. Cannot inject code.',
        );
        return false;
      }

      final beforeBrace = content.substring(0, closingOffset);
      final afterBrace = content.substring(closingOffset);

      content = '$beforeBrace  $formattedCode\n$afterBrace';
    }

    await file.writeAsString(content);
    return true;
  }

  String? _extractDeclarationLine(String code) {
    for (final rawLine in code.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('@')) {
        continue;
      }

      return line;
    }

    return null;
  }

  bool _containsLineLike(String source, String candidateLine) {
    final normalized = candidateLine.trim();
    if (normalized.isEmpty) {
      return false;
    }

    final pattern = RegExp(
      '^\\s*${RegExp.escape(normalized)}\\s*\$',
      multiLine: true,
    );

    return pattern.hasMatch(source);
  }

  bool _containsSnippet(String source, String snippet) {
    final normalizedSnippet = _normalizeForComparison(snippet);
    if (normalizedSnippet.isEmpty) {
      return false;
    }

    final normalizedSource = _normalizeForComparison(source);
    return normalizedSource.contains(normalizedSnippet);
  }

  String _normalizeForComparison(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
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

  List<String> _readExportStatements(dynamic rawExports) {
    if (rawExports == null) {
      return const [];
    }

    if (rawExports is YamlList) {
      return rawExports
          .map((e) => e.toString().trim())
          .where((stmt) => stmt.isNotEmpty)
          .toList();
    }

    if (rawExports is String) {
      return rawExports
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    }

    throw const FormatException(
      'Invalid export format in sequence.yaml. Expected string, list, or map with code.',
    );
  }

  int _findClassClosingBraceAST(String content) {
    final parseResult = parseString(content: content);

    final classNode = parseResult.unit.declarations
        .whereType<ClassDeclaration>()
        .firstOrNull;

    return classNode?.endToken.offset ?? -1;
  }

  MasonBundle _resolveSequenceBundle(SequenceCode sequence) {
    return switch (sequence) {
      SequenceCode.m => sequenceMBundle,
      SequenceCode.mp => sequenceMpBundle,
      SequenceCode.mr => sequenceMrBundle,
      SequenceCode.mrp => sequenceMrpBundle,
      SequenceCode.r => sequenceRBundle,
      SequenceCode.rp => sequenceRpBundle,
      SequenceCode.rpag => sequenceRpagBundle,
      SequenceCode.rs => sequenceRsBundle,
      SequenceCode.rsp => sequenceRspBundle,
      SequenceCode.rof => sequenceRofBundle,
    };
  }

  String _normalizeBlankLines(String source) {
    return source.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}
