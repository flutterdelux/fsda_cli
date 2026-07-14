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
    })
    args,
  ) async {
    final sliceName = args.slice;
    final featureName = args.feature;
    final moduleName = args.module;
    final sequence = args.sequence;
    final methodName = args.method;

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
      await fileService!.generateTemplate(
        path: featureRoot,
        files: standaloneFilesToSave,
      );

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

      await _injectDataSourceSection(
        section: remoteDsContract,
        sectionName: 'remote_data_source_contract',
        path: p.join(
          featureRoot,
          'data',
          'datasources',
          '${args.feature}_remote_data_source.dart',
        ),
        isMutation: isMutation,
      );

      await _injectDataSourceSection(
        section: remoteDsImpl,
        sectionName: 'remote_data_source_impl',
        path: p.join(
          featureRoot,
          'data',
          'datasources',
          '${args.feature}_remote_data_source_impl.dart',
        ),
        isMutation: isMutation,
      );

      await _injectDataSourceSection(
        section: localDsContract,
        sectionName: 'local_data_source_contract',
        path: p.join(
          featureRoot,
          'data',
          'datasources',
          '${args.feature}_local_data_source.dart',
        ),
        isMutation: isMutation,
      );

      await _injectDataSourceSection(
        section: localDsImpl,
        sectionName: 'local_data_source_impl',
        path: p.join(
          featureRoot,
          'data',
          'datasources',
          '${args.feature}_local_data_source_impl.dart',
        ),
        isMutation: isMutation,
      );

      final repoContractPath = p.join(
        featureRoot,
        'domain',
        'repositories',
        '${args.feature}_repository.dart',
      );
      await _injectImports(
        path: repoContractPath,
        imports: repoContract.imports,
      );
      await _injectCode(
        path: repoContractPath,
        code: repoContract.code,
        isMutation: isMutation,
      );

      final repoImplPath = p.join(
        featureRoot,
        'data',
        'repositories',
        '${args.feature}_repository_impl.dart',
      );
      await _injectImports(path: repoImplPath, imports: repoImpl.imports);
      await _injectCode(
        path: repoImplPath,
        code: repoImpl.code,
        isMutation: isMutation,
      );

      if (exportMap != null && exportMap.isNotEmpty) {
        progress.update('Registering export to feature barrel...');
        await _updateFeatureBarrelStructured(
          path: p.join(featureRoot, '${featureName}_feature.dart'),
          exportMap: exportMap,
        );
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
    } catch (e) {
      progress.fail('Failed to stitch slice: $e');
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

  Future<void> _injectDataSourceSection({
    required _SequenceSection section,
    required String path,
    required String sectionName,
    required bool isMutation,
  }) async {
    if (section.imports.trim().isEmpty && section.code.trim().isEmpty) {
      return;
    }

    if (!await File(path).exists()) {
      throw Exception(
        'Target file for "$sectionName" not found: $path. Regenerate baseline files for this feature, then rerun gen-slice.',
      );
    }

    await _injectImports(path: path, imports: section.imports);
    await _injectCode(path: path, code: section.code, isMutation: isMutation);
  }

  Future<void> _injectImports({
    required String path,
    required String imports,
  }) async {
    final file = File(path);
    if (!await file.exists()) return;

    final importLines = imports
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.startsWith('import '))
        .toList();

    if (importLines.isEmpty) {
      return;
    }

    String content = await file.readAsString();
    final lines = content.split('\n');

    final existingImports = lines.map((line) => line.trim()).toSet();
    final missingImports = importLines
        .where((line) => !existingImports.contains(line))
        .toList();

    if (missingImports.isEmpty) {
      return;
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
  }

  Future<void> _injectCode({
    required String path,
    required String code,
    required bool isMutation,
  }) async {
    if (code.trim().isEmpty) return;

    final file = File(path);
    if (!await file.exists()) return;

    String content = await file.readAsString();
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
      final closingOffset = _findClassClosingBraceAST(content);

      if (closingOffset == -1) {
        logger.error(
          'Failed to find class closing brace in $path. Cannot inject code.',
        );
        return;
      }

      final beforeBrace = content.substring(0, closingOffset);
      final afterBrace = content.substring(closingOffset);

      content = '$beforeBrace  $formattedCode\n$afterBrace';
    }

    await file.writeAsString(content);
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
