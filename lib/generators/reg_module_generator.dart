import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../generated/bricks/reg_module_bundle.dart';
import '../services/memory_generator_target.dart';
import '../visitors/app_router_visitor.dart';
import '../visitors/di_visitor.dart';
import '../visitors/failure_x_visitor.dart';
import '../visitors/main_app_visitor.dart';
import 'base_generator.dart';

class RegModuleGenerator
    extends BaseGenerator<void, ({String app, String module})> {
  RegModuleGenerator({required super.logger, required super.fileService});

  @override
  Future<void> generate(({String app, String module}) arg) async {
    final appName = arg.app;
    final moduleName = arg.module;

    final appPath = p.join(Directory.current.path, 'apps', appName);
    final appLibPath = p.join(appPath, 'lib');
    final moduleSnake = moduleName;

    logger.info(
      'Genering module structure for "$moduleName" into "$appName"...',
    );

    final memoryGeneratorTarget = MemoryGeneratorTarget();
    final generator = await MasonGenerator.fromBundle(regModuleBundle);
    await generator.generate(
      memoryGeneratorTarget,
      vars: <String, dynamic>{'app': appName, 'module': moduleName},
    );

    String? regYamlRaw;
    final standaloneFilesToSave = <String, List<int>>{};

    for (final entry in memoryGeneratorTarget.files.entries) {
      final filePath = entry.key;
      final fileBytes = entry.value;
      final fileName = p.basename(filePath);

      if (fileName == 'reg.yaml') {
        regYamlRaw = utf8.decode(fileBytes);
        continue;
      }

      standaloneFilesToSave[filePath] = fileBytes;
    }

    if (regYamlRaw == null) {
      throw Exception('reg.yaml not found in the generated reg_module files.');
    }

    if (fileService == null) {
      throw Exception('fileService is not initialized.');
    }

    await fileService!.generateTemplate(
      path: p.join(appLibPath, 'modules', moduleSnake),
      files: standaloneFilesToSave,
    );

    logger.info('Injecting module configuration into $appName...');

    await _injectDependency(
      filePath: p.join(appPath, 'pubspec.yaml'),
      moduleSnake: moduleSnake,
    );

    final doc = loadYaml(regYamlRaw) as YamlMap;
    await _injectDi(doc['di'] as YamlMap?);
    await _injectRoute(doc['route'] as YamlMap?);
    await _injectL10n(doc['l10n'] as YamlMap?);
    await _injectFailureX(doc['failure_x'] as YamlMap?);

    logger.success(
      'Module "$moduleName" successfully registered in "$appName"!',
    );

    logger.info('📂 Generated Module Folder:');
    logger.log('• apps/$appName/lib/modules/$moduleSnake');

    logger.info('📝 Injected & Modified Files:');
    logger.log('• apps/$appName/pubspec.yaml (Dependency added)');
    logger.log(
      '• apps/$appName/lib/core/di/di.dart (Service locator injected)',
    );
    logger.log('• apps/$appName/lib/app/app_router.dart (Route list updated)');
    logger.log('• apps/$appName/lib/app/main_app.dart (L10n delegate added)');
    logger.log(
      '• apps/$appName/lib/core/extensions/failure_x.dart (Failure localization mapped)',
    );
    logger.log('');
  }

  Future<void> _injectDependency({
    required String filePath,
    required String moduleSnake,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    final dependencyLine =
        '  $moduleSnake:\n    path: ../../modules/$moduleSnake';

    if (lines.join('\n').contains('  $moduleSnake:')) return;

    final markerIndex = lines.indexWhere((l) => l.trim() == 'dependencies:');
    if (markerIndex != -1) {
      lines.insert(markerIndex + 1, dependencyLine);
      await file.writeAsString('${lines.join('\n')}\n');
    }
  }

  Future<void> _injectDi(YamlMap? yamlRaw) async {
    final path = yamlRaw?['path'] as String?;
    final imports = yamlRaw?['imports'] as YamlList?;
    final code = yamlRaw?['code'] as String?;

    if (path == null) {
      logger.info(
        'No DI configuration found in reg.yaml. Skipping DI injection.',
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      logger.error('DI file not found at path: $path. Skipping DI injection.');
      return;
    }

    if (code == null) {
      logger.info('No DI code found in reg.yaml. Skipping DI injection.');
      return;
    }

    final source = await file.readAsString();
    if (_containsLineLike(source, code)) return;

    final parsed = parseString(content: source);
    final visitor = DiVisitor();
    parsed.unit.visitChildren(visitor);

    if (visitor.initDiBlock == null) return;

    final block = visitor.initDiBlock!;
    final blockInner = source.substring(
      block.leftBracket.end,
      block.rightBracket.offset,
    );
    final braceLineStart = source.lastIndexOf(
      '\n',
      block.rightBracket.offset == 0 ? 0 : block.rightBracket.offset - 1,
    );
    final braceLinePrefix = source.substring(
      braceLineStart == -1 ? 0 : braceLineStart + 1,
      block.rightBracket.offset,
    );
    final braceOnOwnLine = braceLinePrefix.trim().isEmpty;
    final insertOffset = braceOnOwnLine
        ? (braceLineStart == -1
              ? block.rightBracket.offset
              : braceLineStart + 1)
        : block.rightBracket.offset;

    final indent = _resolveFirstNonEmptyIndent(
      source: blockInner,
      fallback: '  ',
    );
    final snippet = _reindentSnippet(code, indent);

    final insertion = blockInner.trim().isEmpty
        ? '$snippet\n'
        : braceOnOwnLine
        ? '$snippet\n'
        : '\n$snippet\n';

    final nextSource = source.replaceRange(
      insertOffset,
      insertOffset,
      insertion,
    );

    final normalizedSource =
        '${_normalizeBlankLines(nextSource).trimRight()}\n';
    final (_, updatedImports) = _insertImports(
      normalizedSource.split('\n'),
      imports,
    );
    final output = updatedImports ?? normalizedSource;
    await file.writeAsString('${_normalizeBlankLines(output).trimRight()}\n');
  }

  Future<void> _injectRoute(YamlMap? yamlRaw) async {
    final path = yamlRaw?['path'] as String?;
    final imports = yamlRaw?['imports'] as YamlList?;
    final code = yamlRaw?['code'] as String?;

    if (path == null) {
      logger.info(
        'No Route configuration found in reg.yaml. Skipping Route injection.',
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      logger.error(
        'Route file not found at path: $path. Skipping Route injection.',
      );
      return;
    }

    if (code == null) {
      logger.info('No Route code found in reg.yaml. Skipping Route injection.');
      return;
    }

    final source = await file.readAsString();
    final routeLine = code.trim().endsWith(',')
        ? code.trim()
        : '${code.trim()},';
    if (_containsLineLike(source, routeLine)) return;

    final parsed = parseString(content: source);
    final visitor = AppRouterVisitor();
    parsed.unit.visitChildren(visitor);

    if (visitor.routesList == null) return;

    final list = visitor.routesList!;
    final innerContent = source.substring(
      list.leftBracket.end,
      list.rightBracket.offset,
    );

    final itemIndent = _resolveFirstNonEmptyIndent(
      source: innerContent,
      fallback: '      ',
    );
    final closingIndent = _lineIndentAtOffset(source, list.rightBracket.offset);
    final bracketLineStart = source.lastIndexOf(
      '\n',
      list.rightBracket.offset == 0 ? 0 : list.rightBracket.offset - 1,
    );
    final bracketLinePrefix = source.substring(
      bracketLineStart == -1 ? 0 : bracketLineStart + 1,
      list.rightBracket.offset,
    );
    final bracketOnOwnLine = bracketLinePrefix.trim().isEmpty;
    final insertOffset = bracketOnOwnLine
        ? (bracketLineStart == -1
              ? list.rightBracket.offset
              : bracketLineStart + 1)
        : list.rightBracket.offset;

    final insertion = innerContent.trim().isEmpty
        ? '$itemIndent$routeLine\n$closingIndent'
        : bracketOnOwnLine
        ? '$itemIndent$routeLine\n'
        : '\n$itemIndent$routeLine\n$closingIndent';

    final nextSource = source.replaceRange(
      insertOffset,
      insertOffset,
      insertion,
    );

    final normalizedSource =
        '${_normalizeBlankLines(nextSource).trimRight()}\n';
    final (_, updatedImports) = _insertImports(
      normalizedSource.split('\n'),
      imports,
    );
    final output = updatedImports ?? normalizedSource;
    await file.writeAsString('${_normalizeBlankLines(output).trimRight()}\n');
  }

  Future<void> _injectL10n(YamlMap? yamlRaw) async {
    final path = yamlRaw?['path'] as String?;
    final imports = yamlRaw?['imports'] as YamlList?;
    final code = yamlRaw?['code'] as String?;

    if (path == null) {
      logger.info(
        'No L10n configuration found in reg.yaml. Skipping L10n injection.',
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      logger.error(
        'L10n file not found at path: $path. Skipping L10n injection.',
      );
      return;
    }

    if (code == null) {
      logger.info('No L10n code found in reg.yaml. Skipping L10n injection.');
      return;
    }

    final source = await file.readAsString();
    final l10nLine = code.trim().endsWith(',')
        ? code.trim()
        : '${code.trim()},';
    if (_containsLineLike(source, l10nLine)) return;

    final parsed = parseString(content: source);
    final visitor = MainAppVisitor();
    parsed.unit.visitChildren(visitor);

    if (visitor.delegatesList == null) return;

    final list = visitor.delegatesList!;
    final innerContent = source.substring(
      list.leftBracket.end,
      list.rightBracket.offset,
    );

    final itemIndent = _resolveFirstNonEmptyIndent(
      source: innerContent,
      fallback: '        ',
    );
    final closingIndent = _lineIndentAtOffset(source, list.rightBracket.offset);
    final bracketLineStart = source.lastIndexOf(
      '\n',
      list.rightBracket.offset == 0 ? 0 : list.rightBracket.offset - 1,
    );
    final bracketLinePrefix = source.substring(
      bracketLineStart == -1 ? 0 : bracketLineStart + 1,
      list.rightBracket.offset,
    );
    final bracketOnOwnLine = bracketLinePrefix.trim().isEmpty;
    final insertOffset = bracketOnOwnLine
        ? (bracketLineStart == -1
              ? list.rightBracket.offset
              : bracketLineStart + 1)
        : list.rightBracket.offset;

    final insertion = innerContent.trim().isEmpty
        ? '$itemIndent$l10nLine\n$closingIndent'
        : bracketOnOwnLine
        ? '$itemIndent$l10nLine\n'
        : '\n$itemIndent$l10nLine\n$closingIndent';

    final newSource = source.replaceRange(
      insertOffset,
      insertOffset,
      insertion,
    );

    final normalizedSource = '${_normalizeBlankLines(newSource).trimRight()}\n';
    final (_, updatedImports) = _insertImports(
      normalizedSource.split('\n'),
      imports,
    );
    final output = updatedImports ?? normalizedSource;
    await file.writeAsString('${_normalizeBlankLines(output).trimRight()}\n');
  }

  Future<void> _injectFailureX(YamlMap? yamlRaw) async {
    final path = yamlRaw?['path'] as String?;
    final imports = yamlRaw?['imports'] as YamlList?;
    final code = yamlRaw?['code'] as String?;

    if (path == null) {
      logger.info(
        'No FailureX configuration found in reg.yaml. Skipping FailureX injection.',
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      logger.error(
        'FailureX file not found at path: $path. Skipping FailureX injection.',
      );
      return;
    }

    if (code == null) {
      logger.info(
        'No FailureX code found in reg.yaml. Skipping FailureX injection.',
      );
      return;
    }

    final source = await file.readAsString();
    final signature = code.split('\n').first.trim();
    if (_containsLineLike(source, signature)) return;

    final parsed = parseString(content: source);
    final visitor = FailureXVisitor();
    parsed.unit.visitChildren(visitor);

    if (visitor.targetReturnStatement == null) return;

    final offset = visitor.targetReturnStatement!.offset;
    final lineStart = source.lastIndexOf('\n', offset == 0 ? 0 : offset - 1);
    final insertOffset = lineStart == -1 ? 0 : lineStart + 1;
    final indent = _lineIndentAtOffset(source, offset);
    final snippet = _reindentSnippet(code, indent);

    final nextSource = source.replaceRange(
      insertOffset,
      insertOffset,
      '$snippet\n\n',
    );

    final normalizedSource =
        '${_normalizeBlankLines(nextSource).trimRight()}\n';
    final (_, updatedImports) = _insertImports(
      normalizedSource.split('\n'),
      imports,
    );
    final output = updatedImports ?? normalizedSource;
    await file.writeAsString('${_normalizeBlankLines(output).trimRight()}\n');
  }

  bool _containsLineLike(String source, String codeLine) {
    final target = codeLine.trim().replaceFirst(RegExp(r',$'), '');
    if (target.isEmpty) return true;

    final pattern = RegExp(
      r'^\s*' + RegExp.escape(target) + r'\s*,?\s*$',
      multiLine: true,
    );
    return pattern.hasMatch(source);
  }

  String _lineIndentAtOffset(String source, int offset) {
    final safeOffset = offset.clamp(0, source.length);
    final lineStart = source.lastIndexOf(
      '\n',
      safeOffset == 0 ? 0 : safeOffset - 1,
    );
    final segmentStart = lineStart == -1 ? 0 : lineStart + 1;
    final segment = source.substring(segmentStart, safeOffset);
    return RegExp(r'^\s*').stringMatch(segment) ?? '';
  }

  String _resolveFirstNonEmptyIndent({
    required String source,
    required String fallback,
  }) {
    for (final line in source.split('\n')) {
      if (line.trim().isEmpty) continue;
      return RegExp(r'^\s*').stringMatch(line) ?? fallback;
    }
    return fallback;
  }

  String _reindentSnippet(String code, String indent) {
    final rawLines = code.trimRight().split('\n');
    final nonEmpty = rawLines.where((line) => line.trim().isNotEmpty).toList();
    if (nonEmpty.isEmpty) return '';

    var minIndent = nonEmpty
        .map((line) => line.length - line.trimLeft().length)
        .reduce((a, b) => a < b ? a : b);

    if (minIndent < 0) {
      minIndent = 0;
    }

    return rawLines
        .map((line) {
          if (line.trim().isEmpty) return '';
          final start = minIndent > line.length ? line.length : minIndent;
          return '$indent${line.substring(start)}';
        })
        .join('\n');
  }

  String _normalizeBlankLines(String source) {
    final sanitized = source.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    return sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}

(bool, String?) _insertImports(List<String> fileLines, YamlList? imports) {
  if (imports == null || imports.isEmpty) return (false, null);

  final fileContent = fileLines.join('\n');
  final validImports = imports
      .map((e) => e.toString())
      .where((i) => !fileContent.contains(i))
      .toList();

  if (validImports.isEmpty) return (false, null);

  final lastImportIndex = fileLines.lastIndexWhere(
    (l) => l.startsWith('import '),
  );

  if (lastImportIndex != -1) {
    fileLines.insertAll(lastImportIndex + 1, validImports);
  } else {
    fileLines.insertAll(0, validImports);
  }

  return (true, fileLines.join('\n'));
}
