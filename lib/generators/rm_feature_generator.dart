import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../services/operation_report_service.dart';
import 'base_generator.dart';

const _postHooks = [
  'flutter gen-l10n',
  'dart run build_runner build --force-jit --delete-conflicting-outputs',
];

class RmFeatureGenerator
    extends
        BaseGenerator<
          void,
          ({String module, String feature, bool hookDisabled})
        > {
  const RmFeatureGenerator({required super.logger, required super.hookService});

  @override
  Future<void> generate(
    ({String module, String feature, bool hookDisabled}) args,
  ) async {
    final moduleName = args.module;
    final featureName = args.feature;
    final hookDisabled = args.hookDisabled;
    final report = OperationReportService();

    final moduleRoot = p.join(Directory.current.path, 'modules', moduleName);
    final moduleDir = Directory(moduleRoot);
    if (!await moduleDir.exists()) {
      logger.error('Module "$moduleName" does not exist.');
      exitCode = 1;
      report.logSummary(logger, operationLabel: 'fsda rm-feature');
      return;
    }

    final featureDir = Directory(
      p.join(moduleRoot, 'lib', 'src', 'features', featureName),
    );
    final moduleBarrelPath = p.join(moduleRoot, 'lib', '$moduleName.dart');
    final exceptionPath = p.join(
      moduleRoot,
      'lib',
      'src',
      'shared',
      'data',
      'errors',
      '${moduleName}_exception.dart',
    );
    final failurePath = p.join(
      moduleRoot,
      'lib',
      'src',
      'shared',
      'domain',
      'errors',
      '${moduleName}_failure.dart',
    );
    final failureXPath = p.join(
      moduleRoot,
      'lib',
      'src',
      'shared',
      'ui',
      'extensions',
      '${moduleName}_failure_x.dart',
    );

    try {
      if (await featureDir.exists()) {
        await featureDir.delete(recursive: true);
        logger.info(
          'Removed feature directory: modules/$moduleName/lib/src/features/$featureName',
        );
        report.addRemoved(featureDir.path);
      } else {
        report.addSkipped(featureDir.path);
      }

      final removedExport = await _removeFeatureExport(
        moduleBarrelPath: moduleBarrelPath,
        featureName: featureName,
      );
      if (removedExport) {
        report.addUpdated(moduleBarrelPath);
      } else {
        report.addSkipped(moduleBarrelPath);
      }

      final removedExceptionCase = await _removeExceptionFeaturePrefix(
        path: exceptionPath,
        featureName: featureName,
      );
      _recordFileMutation(
        report: report,
        path: exceptionPath,
        changed: removedExceptionCase,
      );

      final removedFailureCase = await _removeFailureFeaturePrefix(
        path: failurePath,
        featureName: featureName,
      );
      _recordFileMutation(
        report: report,
        path: failurePath,
        changed: removedFailureCase,
      );

      final removedFailureXCase = await _removeFailureXFeaturePrefix(
        path: failureXPath,
        moduleName: moduleName,
        featureName: featureName,
      );
      _recordFileMutation(
        report: report,
        path: failureXPath,
        changed: removedFailureXCase,
      );

      final touchedArbFiles = await _removeFeatureArbEntries(
        moduleName: moduleName,
        featureName: featureName,
      );
      if (touchedArbFiles.isEmpty) {
        logger.info(
          'No feature-scoped ARB keys found for "$featureName" in module "$moduleName".',
        );
      } else {
        for (final filePath in touchedArbFiles) {
          report.addUpdated(filePath);
        }
      }

      await hookService!.runHook(
        hooks: _postHooks,
        workingDirectory: moduleRoot,
        logger: logger,
        disabled: hookDisabled,
        operationLabel: 'fsda rm-feature',
      );

      logger.success(
        'Feature "$featureName" rollback completed in module "$moduleName".',
      );
      report.logSummary(logger, operationLabel: 'fsda rm-feature');
    } catch (e) {
      logger.error('Failed to remove feature "$featureName": $e');
      exitCode = 1;
      report.logSummary(logger, operationLabel: 'fsda rm-feature');
    }
  }

  Future<bool> _removeFeatureExport({
    required String moduleBarrelPath,
    required String featureName,
  }) async {
    final moduleBarrelFile = File(moduleBarrelPath);
    if (!await moduleBarrelFile.exists()) {
      logger.info('Module barrel file not found: $moduleBarrelPath');
      return false;
    }

    final exportStatement =
        "export 'src/features/$featureName/${featureName}_feature.dart';";

    final lines = await moduleBarrelFile.readAsLines();
    final filtered = lines
        .where((line) => line.trim() != exportStatement)
        .toList();

    if (filtered.length == lines.length) {
      return false;
    }

    final normalized = filtered
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    await moduleBarrelFile.writeAsString('${normalized.trimRight()}\n');
    return true;
  }

  void _recordFileMutation({
    required OperationReportService report,
    required String path,
    required bool changed,
  }) {
    if (changed) {
      report.addUpdated(path);
      return;
    }

    report.addSkipped(path);
  }

  Future<bool> _removeExceptionFeaturePrefix({
    required String path,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final prefix = featureName.camelCase;

    var source = await file.readAsString();
    final before = source;

    source = _removeExceptionFactoriesByPrefix(source: source, prefix: prefix);

    source = _removeWhenCasesByPrefix(source: source, prefix: prefix);
    source = _normalizeSource(source);

    if (source == before) {
      return false;
    }

    await file.writeAsString('$source\n');
    return true;
  }

  Future<bool> _removeFailureFeaturePrefix({
    required String path,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final source = await file.readAsString();
    final before = source;
    final prefix = featureName.camelCase;

    final enumRegex = RegExp(
      r'(enum\s+[A-Za-z_]\w*\s+implements\s+Failure\s*\{)([\s\S]*?)(\})',
      multiLine: true,
    );
    final match = enumRegex.firstMatch(source);
    if (match == null) {
      return false;
    }

    final body = match.group(2)!;
    final bodyTrimRight = body.trimRight();
    final hasMultilineBody = bodyTrimRight.contains('\n');

    final cases = body
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();

    final nextCases = cases
        .where((entry) => !entry.startsWith(prefix))
        .toList();
    if (nextCases.length == cases.length) {
      return false;
    }

    final updatedBody = hasMultilineBody
        ? _buildMultilineEnumBody(body: body, values: nextCases)
        : ' ${nextCases.join(', ')} ';

    final updated = source.replaceRange(
      match.start,
      match.end,
      '${match.group(1)!}$updatedBody${match.group(3)!}',
    );

    if (updated == before) {
      return false;
    }

    await file.writeAsString('${_normalizeSource(updated)}\n');
    return true;
  }

  String _buildMultilineEnumBody({
    required String body,
    required List<String> values,
  }) {
    final indentMatch = RegExp(r'\n([ \t]*)[A-Za-z_]\w*').firstMatch(body);
    final indent = indentMatch?.group(1) ?? '  ';

    if (values.isEmpty) {
      return '\n';
    }

    return '\n$indent${values.join(',\n$indent')}\n';
  }

  Future<bool> _removeFailureXFeaturePrefix({
    required String path,
    required String moduleName,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final modulePascal = moduleName.pascalCase;
    final prefix = RegExp.escape(featureName.camelCase);
    final source = await file.readAsString();

    final casePattern = RegExp(
      '^[ \\t]*${RegExp.escape(modulePascal)}Failure\\.$prefix[A-Za-z0-9_]*\\s*=>[^\\n]*\\n?',
      multiLine: true,
    );

    final updated = source.replaceAll(casePattern, '');
    if (updated == source) {
      return false;
    }

    await file.writeAsString('${_normalizeSource(updated)}\n');
    return true;
  }

  Future<Set<String>> _removeFeatureArbEntries({
    required String moduleName,
    required String featureName,
  }) async {
    final touchedPaths = <String>{};
    final l10nDir = Directory(
      p.join(Directory.current.path, 'modules', moduleName, 'lib', 'l10n'),
    );

    if (!await l10nDir.exists()) {
      return touchedPaths;
    }

    final arbFiles = l10nDir.listSync().whereType<File>().where(
      (file) => file.path.endsWith('.arb'),
    );

    final featureCamel = featureName.camelCase;
    final featurePascal = featureName.pascalCase;
    const encoder = JsonEncoder.withIndent('  ');

    for (final arbFile in arbFiles) {
      final raw = await arbFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        continue;
      }

      final map = Map<String, dynamic>.from(decoded);
      final keysToRemove = map.keys
          .where(
            (key) => _matchesFeatureScopedArbKey(
              key: key,
              featureCamel: featureCamel,
              featurePascal: featurePascal,
            ),
          )
          .toList(growable: false);

      if (keysToRemove.isEmpty) {
        continue;
      }

      for (final key in keysToRemove) {
        map.remove(key);
      }

      await arbFile.writeAsString('${encoder.convert(map)}\n');
      touchedPaths.add(arbFile.path);
      logger.info(
        'Removed ${keysToRemove.length} ARB entr${keysToRemove.length == 1 ? 'y' : 'ies'} from ${p.basename(arbFile.path)} for feature "$featureName".',
      );
    }

    return touchedPaths;
  }

  bool _matchesFeatureScopedArbKey({
    required String key,
    required String featureCamel,
    required String featurePascal,
  }) {
    final normalizedKey = key.startsWith('@') ? key.substring(1) : key;

    return normalizedKey.startsWith(featureCamel) ||
        normalizedKey.startsWith('failure$featurePascal');
  }

  String _removeWhenCasesByPrefix({
    required String source,
    required String prefix,
  }) {
    var next = source;

    final messageRegex = RegExp(r'String get message => when\(([\s\S]*?)\);');
    next = next.replaceFirstMapped(messageRegex, (match) {
      final body = match.group(1)!;
      final updatedBody = _removeWhenCaseEntriesByPrefix(
        body: body,
        prefix: prefix,
      );
      if (updatedBody == body) {
        return match.group(0)!;
      }

      return 'String get message => when($updatedBody);';
    });

    final toFailureRegex = RegExp(
      r'Failure toFailure\(\) => when\(([\s\S]*?)\);',
    );
    next = next.replaceFirstMapped(toFailureRegex, (match) {
      final body = match.group(1)!;
      final updatedBody = _removeWhenCaseEntriesByPrefix(
        body: body,
        prefix: prefix,
      );
      if (updatedBody == body) {
        return match.group(0)!;
      }

      return 'Failure toFailure() => when($updatedBody);';
    });

    return next;
  }

  String _removeExceptionFactoriesByPrefix({
    required String source,
    required String prefix,
  }) {
    final lines = source.split('\n');
    final next = <String>[];

    final factoryPattern = RegExp(
      r'^\s*(?:const\s+)?factory\s+[A-Za-z_]\w*Exception\.([A-Za-z_]\w*)\s*\(',
    );

    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      final match = factoryPattern.firstMatch(line);

      if (match == null) {
        next.add(line);
        index += 1;
        continue;
      }

      final caseName = match.group(1)!;
      if (!caseName.startsWith(prefix)) {
        next.add(line);
        index += 1;
        continue;
      }

      while (index < lines.length) {
        final currentLine = lines[index];
        index += 1;
        if (currentLine.contains(';')) {
          break;
        }
      }
    }

    return next.join('\n');
  }

  String _removeWhenCaseEntriesByPrefix({
    required String body,
    required String prefix,
  }) {
    final entries = _splitTopLevelCommaEntries(body);
    if (entries.isEmpty) {
      return body;
    }

    final filtered = entries.where((entry) {
      final caseMatch = RegExp(r'^\s*([A-Za-z_]\w*)\s*:').firstMatch(entry);
      final caseName = caseMatch?.group(1);
      if (caseName == null) {
        return true;
      }
      return !caseName.startsWith(prefix);
    }).toList();

    if (filtered.length == entries.length) {
      return body;
    }

    final hasMultiline = body.contains('\n');
    if (!hasMultiline) {
      return filtered.join(', ').trimRight();
    }

    final indentMatch = RegExp(r'\n([ \t]*)[A-Za-z_]\w*\s*:').firstMatch(body);
    final indent = indentMatch?.group(1) ?? '      ';
    if (filtered.isEmpty) {
      return '\n$indent';
    }

    return '\n$indent${filtered.join(',\n$indent')}';
  }

  List<String> _splitTopLevelCommaEntries(String source) {
    final values = <String>[];
    var start = 0;
    var depthRound = 0;
    var depthSquare = 0;
    var depthCurly = 0;
    var depthAngle = 0;

    for (var index = 0; index < source.length; index++) {
      final char = source[index];
      if (char == '(') {
        depthRound++;
        continue;
      }
      if (char == ')') {
        if (depthRound > 0) {
          depthRound--;
        }
        continue;
      }
      if (char == '[') {
        depthSquare++;
        continue;
      }
      if (char == ']') {
        if (depthSquare > 0) {
          depthSquare--;
        }
        continue;
      }
      if (char == '{') {
        depthCurly++;
        continue;
      }
      if (char == '}') {
        if (depthCurly > 0) {
          depthCurly--;
        }
        continue;
      }
      if (char == '<') {
        depthAngle++;
        continue;
      }
      if (char == '>') {
        if (depthAngle > 0) {
          depthAngle--;
        }
        continue;
      }

      if (char == ',') {
        final isTopLevel =
            depthRound == 0 &&
            depthSquare == 0 &&
            depthCurly == 0 &&
            depthAngle == 0;
        if (isTopLevel) {
          final entry = source.substring(start, index).trim();
          if (entry.isNotEmpty) {
            values.add(entry);
          }
          start = index + 1;
        }
      }
    }

    final last = source.substring(start).trim();
    if (last.isNotEmpty) {
      values.add(last);
    }

    return values;
  }

  String _normalizeSource(String source) {
    return source.replaceAll(RegExp(r'\n{3,}'), '\n\n').trimRight();
  }
}
