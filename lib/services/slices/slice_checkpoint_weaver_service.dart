import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:yaml/yaml.dart';

import '../../constants/cli_info.dart';
import '../logger_service.dart';

typedef SliceSequenceSection = ({String imports, String code});

class SliceCheckpointWeaverService {
  final LoggerService logger;

  const SliceCheckpointWeaverService({required this.logger});

  List<String> normalizePostHooks(List<String> hooks) {
    return hooks
        .map((hook) {
          return hook.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
        })
        .where((hook) => hook.isNotEmpty)
        .toList(growable: false);
  }

  SliceSequenceSection readSection({
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

  Future<bool> injectDataSourceSection({
    required SliceSequenceSection section,
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
        'Target file for "$sectionName" not found: $path. Regenerate baseline files for this feature, then rerun the corresponding slice-* command.',
      );
    }

    final importsChanged = await injectImports(
      path: path,
      imports: section.imports,
    );
    final codeChanged = await injectCode(
      path: path,
      code: section.code,
      isMutation: isMutation,
      strict: strict,
    );
    return importsChanged || codeChanged;
  }

  Future<bool> injectImports({
    required String path,
    required String imports,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final importLines = imports
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.startsWith('import '))
        .toList(growable: false);

    if (importLines.isEmpty) {
      return false;
    }

    String content = await file.readAsString();
    final lines = content.split('\n');

    final existingImports = lines.map((line) => line.trim()).toSet();
    final missingImports = importLines
        .where((line) => !existingImports.contains(line))
        .toList(growable: false);

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

  Future<bool> injectCode({
    required String path,
    required String code,
    required bool isMutation,
    required bool strict,
  }) async {
    if (code.trim().isEmpty) {
      return false;
    }

    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

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
      content = content.replaceFirst(
        targetCheckpoint,
        '$targetCheckpoint\n\n  $formattedCode',
      );
    } else {
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

  Future<bool> updateFeatureBarrelStructured({
    required String path,
    YamlMap? exportMap,
    Map<String, List<String>> extraExports = const <String, List<String>>{},
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();
    var changed = false;

    for (final layer in ['data', 'domain', 'logic', 'ui']) {
      final rawExports = exportMap?[layer];
      final statements = <String>[
        ..._readExportStatements(rawExports),
        ...?extraExports[layer],
      ];
      if (statements.isEmpty) {
        continue;
      }

      final uniqueStatements = <String>{};
      final validExports = statements
          .where((stmt) => uniqueStatements.add(stmt))
          .where((stmt) => !existingStatements.contains(stmt))
          .toList(growable: false);

      if (validExports.isEmpty) {
        continue;
      }

      final markerIndex = lines.indexWhere(
        (line) => line.trim() == '// $layer',
      );
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

  List<String> _readExportStatements(dynamic rawExports) {
    if (rawExports == null) {
      return const <String>[];
    }

    if (rawExports is YamlList) {
      return rawExports
          .map((entry) => entry.toString().trim())
          .where((stmt) => stmt.isNotEmpty)
          .toList(growable: false);
    }

    if (rawExports is String) {
      return rawExports
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    }

    throw const FormatException(
      'Invalid export format in sequence.yaml. Expected string, list, or map with code.',
    );
  }

  int _findClassClosingBraceAST(String content) {
    final parseResult = parseString(content: content);

    for (final declaration in parseResult.unit.declarations) {
      if (declaration is ClassDeclaration) {
        return declaration.endToken.offset;
      }
    }

    return -1;
  }

  String _normalizeBlankLines(String source) {
    return source.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}
