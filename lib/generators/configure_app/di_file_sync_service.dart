import 'dart:io';

import 'package:path/path.dart' as p;

import '../../models/infra_template_spec.dart';
import '../../services/logger_service.dart';

typedef CoreDiSyncResult = ({int added, int removed});
typedef ExternalDiSyncResult = ({
  int functionAdded,
  int functionRemoved,
  int fileAdded,
  int fileRemoved,
});
typedef InfraCodeSnippet = ({String packageName, String code});

class DiFileSyncService {
  const DiFileSyncService();

  Future<CoreDiSyncResult> syncCoreDiFile({
    required String appPath,
    required String appName,
    required List<InfraTemplateSpec> allInfraSpecs,
    required List<InfraTemplateSpec> activeInfraSpecs,
    required LoggerService logger,
  }) async {
    final coreDiFile = File(
      p.join(appPath, 'lib', 'core', 'di', 'core_di.dart'),
    );

    if (!await coreDiFile.exists()) {
      logger.error('core_di.dart not found for app "$appName".');
      return (added: 0, removed: 0);
    }

    final original = await coreDiFile.readAsString();
    var updated = _stripLegacyManagedMarkers(original);

    final managedImports = <String>{
      for (final spec in allInfraSpecs) ...spec.coreDiImports,
    };
    final desiredImports = <String>{
      for (final spec in activeInfraSpecs) ...spec.coreDiImports,
    };

    updated = _syncImportsInDartFile(
      source: updated,
      allManagedImports: managedImports,
      desiredImports: desiredImports,
    );

    final allSnippets = _collectSnippets(
      specs: allInfraSpecs,
      readCode: (spec) => spec.coreDiCode,
      indent: 2,
    );

    final activeSnippets = _collectSnippets(
      specs: activeInfraSpecs,
      readCode: (spec) => spec.coreDiCode,
      indent: 2,
    );

    final snippetResult = _syncFunctionSnippets(
      source: updated,
      functionName: 'coreDI',
      allSnippets: allSnippets,
      activeSnippets: activeSnippets,
    );
    updated = '${_normalizeBlankLines(snippetResult.content).trimRight()}\n';

    if (updated != original) {
      await coreDiFile.writeAsString(updated);
    }

    return (added: snippetResult.added, removed: snippetResult.removed);
  }

  Future<ExternalDiSyncResult> syncExternalDiFile({
    required String appPath,
    required String appName,
    required List<InfraTemplateSpec> allInfraSpecs,
    required List<InfraTemplateSpec> activeInfraSpecs,
    required LoggerService logger,
  }) async {
    final externalDiFile = File(
      p.join(appPath, 'lib', 'core', 'di', 'external_di.dart'),
    );

    if (!await externalDiFile.exists()) {
      logger.error('external_di.dart not found for app "$appName".');
      return (
        functionAdded: 0,
        functionRemoved: 0,
        fileAdded: 0,
        fileRemoved: 0,
      );
    }

    final externalFileSync = await _syncExternalConfigFiles(
      appPath: appPath,
      allInfraSpecs: allInfraSpecs,
      activeInfraSpecs: activeInfraSpecs,
    );

    final original = await externalDiFile.readAsString();
    var updated = _stripLegacyManagedMarkers(original);

    final managedImports = <String>{
      for (final spec in allInfraSpecs) ...spec.externalDiImports,
      for (final spec in allInfraSpecs)
        if (_hasExternalConfig(spec)) _buildExternalConfigImport(spec),
      for (final spec in allInfraSpecs) ...spec.externalCodeImports,
    };
    final desiredImports = <String>{
      for (final spec in activeInfraSpecs) ...spec.externalDiImports,
      for (final spec in activeInfraSpecs)
        if (_hasExternalConfig(spec)) _buildExternalConfigImport(spec),
    };

    updated = _syncImportsInDartFile(
      source: updated,
      allManagedImports: managedImports,
      desiredImports: desiredImports,
    );

    final allFunctionSnippets = _collectSnippets(
      specs: allInfraSpecs,
      readCode: (spec) => spec.externalDiCode,
      indent: 2,
    );

    final activeFunctionSnippets = _collectSnippets(
      specs: activeInfraSpecs,
      readCode: (spec) => spec.externalDiCode,
      indent: 2,
    );

    final functionResult = _syncFunctionSnippets(
      source: updated,
      functionName: 'externalDI',
      allSnippets: allFunctionSnippets,
      activeSnippets: activeFunctionSnippets,
    );
    updated = functionResult.content;

    final allLegacyFileSnippets = _collectSnippets(
      specs: allInfraSpecs,
      readCode: (spec) => spec.externalCode,
      indent: 0,
    );

    final legacyFileCleanupResult = _syncFileSnippets(
      source: updated,
      allSnippets: allLegacyFileSnippets,
      activeSnippets: const <InfraCodeSnippet>[],
    );
    updated =
        '${_normalizeBlankLines(legacyFileCleanupResult.content).trimRight()}\n';

    if (updated != original) {
      await externalDiFile.writeAsString(updated);
    }

    return (
      functionAdded: functionResult.added,
      functionRemoved: functionResult.removed,
      fileAdded: externalFileSync.added,
      fileRemoved: externalFileSync.removed,
    );
  }

  Future<({int added, int removed})> _syncExternalConfigFiles({
    required String appPath,
    required List<InfraTemplateSpec> allInfraSpecs,
    required List<InfraTemplateSpec> activeInfraSpecs,
  }) async {
    final allExternalSpecs = allInfraSpecs.where(_hasExternalConfig).toList();
    if (allExternalSpecs.isEmpty) {
      return (added: 0, removed: 0);
    }

    final externalDir = Directory(p.join(appPath, 'lib', 'core', 'externals'));

    final activeExternalSpecs = <String, InfraTemplateSpec>{
      for (final spec in activeInfraSpecs.where(_hasExternalConfig))
        spec.packageName: spec,
    };

    var added = 0;
    var removed = 0;

    for (final spec in allExternalSpecs) {
      final fileName = _buildExternalConfigFileName(spec.packageName);
      final file = File(p.join(externalDir.path, fileName));

      final activeSpec = activeExternalSpecs[spec.packageName];
      if (activeSpec == null) {
        if (await file.exists()) {
          await file.delete();
          removed += 1;
        }
        continue;
      }

      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }

      final nextContent = _buildExternalConfigFileContent(activeSpec);
      if (await file.exists()) {
        final current = await file.readAsString();
        if (current != nextContent) {
          await file.writeAsString(nextContent);
        }
      } else {
        await file.writeAsString(nextContent);
        added += 1;
      }
    }

    return (added: added, removed: removed);
  }

  bool _hasExternalConfig(InfraTemplateSpec spec) {
    final hasExternalCode = spec.externalCode?.trim().isNotEmpty ?? false;
    return hasExternalCode || spec.externalCodeImports.isNotEmpty;
  }

  String _buildExternalConfigImport(InfraTemplateSpec spec) {
    final fileName = _buildExternalConfigFileName(spec.packageName);
    return "import '../externals/$fileName';";
  }

  String _buildExternalConfigFileName(String packageName) {
    final normalized = packageName.startsWith('infra_')
        ? packageName.substring('infra_'.length)
        : packageName;
    return '${normalized}_config.dart';
  }

  String _buildExternalConfigFileContent(InfraTemplateSpec spec) {
    final imports = spec.externalCodeImports.toList()..sort();
    final hasCode = spec.externalCode?.trim().isNotEmpty ?? false;

    final lines = <String>[...imports];
    if (imports.isNotEmpty && hasCode) {
      lines.add('');
    }

    if (hasCode) {
      lines.add(spec.externalCode!.trimRight());
    }

    return '${_normalizeBlankLines(lines.join('\n')).trimRight()}\n';
  }

  String _syncImportsInDartFile({
    required String source,
    required Set<String> allManagedImports,
    required Set<String> desiredImports,
  }) {
    if (allManagedImports.isEmpty && desiredImports.isEmpty) {
      return source;
    }

    final lines = source.split('\n');
    final updatedLines = <String>[];
    final seenDesired = <String>{};

    for (final line in lines) {
      final trimmed = line.trim();
      if (allManagedImports.contains(trimmed)) {
        if (desiredImports.contains(trimmed) &&
            !seenDesired.contains(trimmed)) {
          updatedLines.add(trimmed);
          seenDesired.add(trimmed);
        }
        continue;
      }

      updatedLines.add(line);
    }

    final missingImports = desiredImports.difference(seenDesired).toList()
      ..sort();
    if (missingImports.isNotEmpty) {
      final lastImportIndex = updatedLines.lastIndexWhere(
        (line) => line.trim().startsWith('import '),
      );

      if (lastImportIndex != -1) {
        updatedLines.insertAll(lastImportIndex + 1, missingImports);
      } else {
        updatedLines.insertAll(0, [...missingImports, '']);
      }
    }

    final content = _normalizeBlankLines(updatedLines.join('\n')).trimRight();
    return '$content\n';
  }

  ({String content, int added, int removed}) _syncFunctionSnippets({
    required String source,
    required String functionName,
    required List<InfraCodeSnippet> allSnippets,
    required List<InfraCodeSnippet> activeSnippets,
  }) {
    final offsets = _findFunctionOffsets(
      source: source,
      functionName: functionName,
    );
    if (offsets == null) {
      return (content: source, added: 0, removed: 0);
    }

    var body = source.substring(offsets.openBrace + 1, offsets.closeBrace);
    body = _stripLegacyManagedMarkers(body);

    var removed = 0;
    var added = 0;

    final activePackages = activeSnippets
        .map((snippet) => snippet.packageName)
        .toSet();

    for (final snippet in allSnippets) {
      if (activePackages.contains(snippet.packageName)) continue;

      final before = body;
      body = _removeSnippet(body, snippet.code);
      if (body != before) {
        removed += 1;
      }
    }

    for (final snippet in activeSnippets) {
      if (_containsSnippet(body, snippet.code)) {
        continue;
      }

      if (_containsEquivalentCode(body, snippet.code)) {
        continue;
      }

      body = _appendSnippet(body, snippet.code);
      added += 1;
    }

    body = _normalizeBlankLines(body);
    final updated = source.replaceRange(
      offsets.openBrace + 1,
      offsets.closeBrace,
      body,
    );

    return (content: updated, added: added, removed: removed);
  }

  ({String content, int added, int removed}) _syncFileSnippets({
    required String source,
    required List<InfraCodeSnippet> allSnippets,
    required List<InfraCodeSnippet> activeSnippets,
  }) {
    var updated = _stripLegacyManagedMarkers(source);
    var removed = 0;
    var added = 0;

    final activePackages = activeSnippets
        .map((snippet) => snippet.packageName)
        .toSet();

    for (final snippet in allSnippets) {
      if (activePackages.contains(snippet.packageName)) continue;

      final before = updated;
      updated = _removeSnippet(updated, snippet.code);
      if (updated != before) {
        removed += 1;
      }
    }

    for (final snippet in activeSnippets) {
      if (_containsSnippet(updated, snippet.code)) {
        continue;
      }

      if (_containsEquivalentCode(updated, snippet.code)) {
        continue;
      }

      updated = _appendSnippet(updated, snippet.code);
      added += 1;
    }

    return (content: updated, added: added, removed: removed);
  }

  String _stripLegacyManagedMarkers(String source) {
    return source.replaceAll(
      RegExp(r'^[ \t]*//\s*fsda:configure-app:[^\n]*\n?', multiLine: true),
      '',
    );
  }

  bool _containsSnippet(String source, String snippet) {
    final normalized = snippet.trimRight();
    if (normalized.isEmpty) return true;
    return source.contains(normalized);
  }

  String _removeSnippet(String source, String snippet) {
    final normalized = snippet.trimRight();
    if (normalized.isEmpty) {
      return source;
    }

    final pattern = RegExp(
      r'\n?' + RegExp.escape(normalized) + r'\n?',
      multiLine: true,
    );

    return _normalizeBlankLines(source.replaceAll(pattern, '\n'));
  }

  ({int openBrace, int closeBrace})? _findFunctionOffsets({
    required String source,
    required String functionName,
  }) {
    final pattern = RegExp(
      r'Future<void>\s+' +
          RegExp.escape(functionName) +
          r'\s*\(\s*\)\s*async\s*\{',
      multiLine: true,
    );
    final match = pattern.firstMatch(source);
    if (match == null) return null;

    final openBrace = source.indexOf('{', match.start);
    if (openBrace == -1) return null;

    final closeBrace = _findClosingBrace(source, openBrace);
    if (closeBrace == -1) return null;

    return (openBrace: openBrace, closeBrace: closeBrace);
  }

  int _findClosingBrace(String source, int openBraceOffset) {
    var depth = 0;
    for (var i = openBraceOffset; i < source.length; i++) {
      final ch = source[i];
      if (ch == '{') depth += 1;
      if (ch == '}') {
        depth -= 1;
        if (depth == 0) {
          return i;
        }
      }
    }

    return -1;
  }

  String _appendSnippet(String source, String snippet) {
    final trimmedRight = source.replaceAll(RegExp(r'\s+$'), '');
    final normalized = snippet.trimRight();
    if (normalized.isEmpty) {
      return source;
    }

    if (trimmedRight.trim().isEmpty) {
      return '\n$normalized\n';
    }

    return '$trimmedRight\n\n$normalized\n';
  }

  List<InfraCodeSnippet> _collectSnippets({
    required List<InfraTemplateSpec> specs,
    required String? Function(InfraTemplateSpec spec) readCode,
    required int indent,
  }) {
    final snippets = <InfraCodeSnippet>[];

    for (final spec in specs) {
      final code = readCode(spec);
      if (code == null) {
        continue;
      }

      snippets.add((
        packageName: spec.packageName,
        code: _indentCode(code, indent),
      ));
    }

    return snippets;
  }

  String _indentCode(String code, int spaces) {
    final indent = _indent(spaces);
    final lines = code.trimRight().split('\n');
    return lines.map((line) => line.isEmpty ? '' : '$indent$line').join('\n');
  }

  bool _containsEquivalentCode(String source, String code) {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) return true;

    if (source.contains(trimmedCode)) {
      return true;
    }

    final registrationPair = _extractRegistrationPair(trimmedCode);
    if (registrationPair != null) {
      final pairPattern = RegExp(
        r'register[A-Za-z0-9_]*\s*<\s*' +
            RegExp.escape(registrationPair.abstraction) +
            r'\s*>\s*\([\s\S]*?=>\s*' +
            RegExp.escape(registrationPair.implementation) +
            r'\s*\(',
      );
      if (pairPattern.hasMatch(source)) {
        return true;
      }
    }

    final firstLine = trimmedCode
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');

    if (firstLine.isEmpty) return true;
    return source.contains(firstLine);
  }

  ({String abstraction, String implementation})? _extractRegistrationPair(
    String code,
  ) {
    final match = RegExp(
      r'register[A-Za-z0-9_]*\s*<\s*([^>]+?)\s*>\s*\([\s\S]*?=>\s*([A-Za-z0-9_\.]+)\s*\(',
    ).firstMatch(code);

    if (match == null) return null;

    final abstraction = match.group(1)?.trim();
    final implementation = match.group(2)?.trim();
    if (abstraction == null || abstraction.isEmpty) return null;
    if (implementation == null || implementation.isEmpty) return null;

    return (abstraction: abstraction, implementation: implementation);
  }

  String _normalizeBlankLines(String source) {
    return source.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  String _indent(int spaces) {
    return ' ' * spaces;
  }
}
