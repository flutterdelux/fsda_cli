import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_info.dart';
import '../enums/data_source_mode.dart';
import '../generated/bricks/feature_bundle.dart';
import 'base_generator.dart';

const _postHooks = ['flutter gen-l10n'];

class FeatureGenerator
    extends
        BaseGenerator<
          void,
          ({String feature, String module, DataSourceMode dataSourceMode})
        > {
  FeatureGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
  });

  @override
  Future<void> generate(
    ({String feature, String module, DataSourceMode dataSourceMode}) args,
  ) async {
    final feature = args.feature;
    final module = args.module;
    final dataSourceMode = args.dataSourceMode;

    final barrelFilePath = p.join(
      Directory.current.path,
      'modules',
      module,
      'lib',
      '$module.dart',
    );

    final barrelFile = File(barrelFilePath);
    if (!barrelFile.existsSync()) {
      logger.error(
        '$barrelFilePath does not exist. Please ensure the "$module" barrel file exists.',
      );
      return;
    }

    final targetDir = Directory(
      p.join(
        Directory.current.path,
        'modules',
        module,
        'lib',
        'src',
        'features',
        feature,
      ),
    );

    if (await targetDir.exists()) {
      logger.error('Feature "$feature" already exists at ${targetDir.path}');
      return;
    }

    try {
      final progress = logger.progress(
        'Baking feature "$feature" via Mason...',
      );

      final generator = await MasonGenerator.fromBundle(featureBundle);
      final target = DirectoryGeneratorTarget(targetDir);

      final generatedFiles = await generator.generate(
        target,
        vars: <String, dynamic>{
          'feature': feature,
          'module': module,
          'retrieval_check_point': CliInfo.retrievalCheckpoint,
          'mutation_check_point': CliInfo.mutationCheckpoint,
        },
      );
      progress.complete(
        'Baked ${generatedFiles.length} files into modules/$module/src/features/$feature',
      );

      await _applyDataSourceMode(
        featureRoot: targetDir.path,
        featureName: feature,
        dataSourceMode: dataSourceMode,
      );

      await _syncFeatureBarrelDataExports(
        featureRoot: targetDir.path,
        featureName: feature,
      );

      await _injectFeatureNotFoundContracts(
        moduleName: module,
        featureName: feature,
      );

      final arbInjected = await _injectArbBoundary(
        moduleName: module,
        featureName: feature,
      );
      if (arbInjected) {
        final progress = logger.progress('Running post-hooks for "$feature"');
        await hookService!.runHook(
          hooks: _postHooks,
          workingDirectory: p.join(Directory.current.path, 'modules', module),
        );
        progress.complete('Completed post-hooks for "$feature"');
      }

      await _updateModuleBarrel(
        moduleBarrelPath: barrelFilePath,
        moduleSnake: module,
        featureSnake: feature,
      );
    } catch (e) {
      logger.error('$e');
      return;
    }
  }

  Future<void> regenerate(
    ({String feature, String module, DataSourceMode dataSourceMode}) args,
  ) async {
    final feature = args.feature;
    final module = args.module;
    final dataSourceMode = args.dataSourceMode;

    final targetDir = Directory(
      p.join(
        Directory.current.path,
        'modules',
        module,
        'lib',
        'src',
        'features',
        feature,
      ),
    );

    if (!await targetDir.exists()) {
      logger.error(
        'Feature "$feature" does not exist in module "$module". Run gen-feature first.',
      );
      return;
    }

    Directory? tempDir;
    try {
      final progress = logger.progress(
        'Refreshing baseline files for feature "$feature"...',
      );

      tempDir = await Directory.systemTemp.createTemp(
        'fsda_regen_${module}_${feature}_',
      );

      final tempFeatureRoot = p.join(tempDir.path, feature);
      await Directory(tempFeatureRoot).create(recursive: true);

      final generator = await MasonGenerator.fromBundle(featureBundle);
      await generator.generate(
        DirectoryGeneratorTarget(Directory(tempFeatureRoot)),
        vars: <String, dynamic>{
          'feature': feature,
          'module': module,
          'retrieval_check_point': CliInfo.retrievalCheckpoint,
          'mutation_check_point': CliInfo.mutationCheckpoint,
        },
      );

      await _applyDataSourceMode(
        featureRoot: tempFeatureRoot,
        featureName: feature,
        dataSourceMode: dataSourceMode,
      );

      final syncResult = await _copyMissingFiles(
        sourceRoot: tempFeatureRoot,
        targetRoot: targetDir.path,
      );

      await _syncFeatureBarrelDataExports(
        featureRoot: targetDir.path,
        featureName: feature,
      );

      progress.complete(
        'Baseline refresh completed. Added ${syncResult.addedCount} missing file(s), kept ${syncResult.keptCount} existing file(s).',
      );
    } catch (e) {
      logger.error('$e');
      return;
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  Future<void> _applyDataSourceMode({
    required String featureRoot,
    required String featureName,
    required DataSourceMode dataSourceMode,
  }) async {
    if (dataSourceMode == DataSourceMode.both) {
      return;
    }

    await _rewriteRepositoryImplForMode(
      featureRoot: featureRoot,
      featureName: featureName,
      dataSourceMode: dataSourceMode,
    );

    if (!dataSourceMode.includeLocal) {
      await _deleteIfExists(
        p.join(
          featureRoot,
          'data',
          'datasources',
          '${featureName}_local_data_source.dart',
        ),
      );
      await _deleteIfExists(
        p.join(
          featureRoot,
          'data',
          'datasources',
          '${featureName}_local_data_source_impl.dart',
        ),
      );

      await _removeMatchingLines(
        path: p.join(featureRoot, '${featureName}_feature.dart'),
        matchers: const [
          '_local_data_source.dart',
          '_local_data_source_impl.dart',
        ],
      );
    }

    if (!dataSourceMode.includeRemote) {
      await _deleteIfExists(
        p.join(
          featureRoot,
          'data',
          'datasources',
          '${featureName}_remote_data_source.dart',
        ),
      );
      await _deleteIfExists(
        p.join(
          featureRoot,
          'data',
          'datasources',
          '${featureName}_remote_data_source_impl.dart',
        ),
      );

      await _removeMatchingLines(
        path: p.join(featureRoot, '${featureName}_feature.dart'),
        matchers: const [
          '_remote_data_source.dart',
          '_remote_data_source_impl.dart',
        ],
      );
    }
  }

  Future<void> _rewriteRepositoryImplForMode({
    required String featureRoot,
    required String featureName,
    required DataSourceMode dataSourceMode,
  }) async {
    final repositoryImplPath = p.join(
      featureRoot,
      'data',
      'repositories',
      '${featureName}_repository_impl.dart',
    );

    final file = File(repositoryImplPath);
    if (!await file.exists()) {
      return;
    }

    final nextContent = _buildRepositoryImplContent(
      featureName: featureName,
      dataSourceMode: dataSourceMode,
    );

    await file.writeAsString(nextContent);
  }

  String _buildRepositoryImplContent({
    required String featureName,
    required DataSourceMode dataSourceMode,
  }) {
    final featurePascal = featureName.pascalCase;
    final featureCamel = featureName.camelCase;

    final buffer = StringBuffer();
    buffer.writeln("import 'package:app_core/app_core.dart';");
    buffer.writeln();
    buffer.writeln(
      "import '../../domain/repositories/${featureName}_repository.dart';",
    );
    if (dataSourceMode.includeLocal) {
      buffer.writeln(
        "import '../datasources/${featureName}_local_data_source.dart';",
      );
    }
    if (dataSourceMode.includeRemote) {
      buffer.writeln(
        "import '../datasources/${featureName}_remote_data_source.dart';",
      );
    }

    buffer.writeln();
    buffer.writeln('class ${featurePascal}RepositoryImpl');
    buffer.writeln('    with RepositoryExceptionHandler');
    buffer.writeln('    implements ${featurePascal}Repository {');
    buffer.writeln('  final AppLogger _log;');

    if (dataSourceMode == DataSourceMode.both) {
      buffer.writeln('  final NetworkInfo _networkInfo;');
    }
    if (dataSourceMode.includeLocal) {
      buffer.writeln(
        '  final ${featurePascal}LocalDataSource _localDataSource;',
      );
    }
    if (dataSourceMode.includeRemote) {
      buffer.writeln(
        '  final ${featurePascal}RemoteDataSource _remoteDataSource;',
      );
    }

    buffer.writeln();
    buffer.writeln('  const ${featurePascal}RepositoryImpl({');
    buffer.writeln('    required AppLogger appLogger,');
    if (dataSourceMode == DataSourceMode.both) {
      buffer.writeln('    required NetworkInfo networkInfo,');
    }
    if (dataSourceMode.includeLocal) {
      buffer.writeln(
        '    required ${featurePascal}LocalDataSource ${featureCamel}LocalDataSource,',
      );
    }
    if (dataSourceMode.includeRemote) {
      buffer.writeln(
        '    required ${featurePascal}RemoteDataSource ${featureCamel}RemoteDataSource,',
      );
    }

    buffer.write('  }) : _log = appLogger');
    if (dataSourceMode == DataSourceMode.both) {
      buffer.write(',\n       _networkInfo = networkInfo');
    }
    if (dataSourceMode.includeLocal) {
      buffer.write(
        ',\n       _localDataSource = ${featureCamel}LocalDataSource',
      );
    }
    if (dataSourceMode.includeRemote) {
      buffer.write(
        ',\n       _remoteDataSource = ${featureCamel}RemoteDataSource',
      );
    }
    buffer.writeln(';');

    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  AppLogger get log => _log;');
    buffer.writeln();
    buffer.writeln('  ${CliInfo.retrievalCheckpoint}');
    buffer.writeln();
    buffer.writeln('  ${CliInfo.mutationCheckpoint}');
    buffer.writeln('}');

    return buffer.toString();
  }

  Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<({int addedCount, int keptCount})> _copyMissingFiles({
    required String sourceRoot,
    required String targetRoot,
  }) async {
    var addedCount = 0;
    var keptCount = 0;

    final sourceDir = Directory(sourceRoot);
    if (!await sourceDir.exists()) {
      return (addedCount: addedCount, keptCount: keptCount);
    }

    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is! File) continue;

      final relativePath = p.relative(entity.path, from: sourceRoot);
      final targetFile = File(p.join(targetRoot, relativePath));

      if (await targetFile.exists()) {
        keptCount++;
        continue;
      }

      await targetFile.parent.create(recursive: true);
      await entity.copy(targetFile.path);
      addedCount++;
    }

    return (addedCount: addedCount, keptCount: keptCount);
  }

  Future<void> _syncFeatureBarrelDataExports({
    required String featureRoot,
    required String featureName,
  }) async {
    final barrelFile = File(p.join(featureRoot, '${featureName}_feature.dart'));
    if (!await barrelFile.exists()) {
      return;
    }

    final lines = await barrelFile.readAsLines();

    final managedExports = <String, String>{
      "export 'data/datasources/${featureName}_local_data_source.dart';": p
          .join('data', 'datasources', '${featureName}_local_data_source.dart'),
      "export 'data/datasources/${featureName}_local_data_source_impl.dart';": p
          .join(
            'data',
            'datasources',
            '${featureName}_local_data_source_impl.dart',
          ),
      "export 'data/datasources/${featureName}_remote_data_source.dart';": p
          .join(
            'data',
            'datasources',
            '${featureName}_remote_data_source.dart',
          ),
      "export 'data/datasources/${featureName}_remote_data_source_impl.dart';":
          p.join(
            'data',
            'datasources',
            '${featureName}_remote_data_source_impl.dart',
          ),
      "export 'data/repositories/${featureName}_repository_impl.dart';": p.join(
        'data',
        'repositories',
        '${featureName}_repository_impl.dart',
      ),
    };

    final exportState = <String, bool>{};
    for (final entry in managedExports.entries) {
      exportState[entry.key] = await File(
        p.join(featureRoot, entry.value),
      ).exists();
    }

    lines.removeWhere((line) {
      final exists = exportState[line.trim()];
      return exists != null && !exists;
    });

    var dataMarkerIndex = lines.indexWhere((line) => line.trim() == '// data');
    if (dataMarkerIndex == -1) {
      lines.insert(0, '// data');
      dataMarkerIndex = 0;
    }

    final nextSectionIndex = lines.indexWhere(
      (line) => line.trim().startsWith('// ') && line.trim() != '// data',
      dataMarkerIndex + 1,
    );
    var insertIndex = nextSectionIndex == -1 ? lines.length : nextSectionIndex;

    final existingStatements = lines.map((line) => line.trim()).toSet();
    for (final exportLine in managedExports.keys) {
      final shouldExist = exportState[exportLine] ?? false;
      if (shouldExist && !existingStatements.contains(exportLine)) {
        lines.insert(insertIndex, exportLine);
        insertIndex++;
        existingStatements.add(exportLine);
      }
    }

    await barrelFile.writeAsString('${lines.join('\n').trimRight()}\n');
  }

  Future<void> _removeMatchingLines({
    required String path,
    required List<String> matchers,
  }) async {
    final file = File(path);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    final filtered = lines
        .where((line) => !matchers.any((matcher) => line.contains(matcher)))
        .toList();

    await file.writeAsString('${filtered.join('\n')}\n');
  }

  Future<void> _updateModuleBarrel({
    required String moduleBarrelPath,
    required String moduleSnake,
    required String featureSnake,
  }) async {
    if (fileService == null) {
      logger.error('FileService is required to update module barrel file');
      return;
    }

    final exportStatement =
        "export 'src/features/$featureSnake/${featureSnake}_feature.dart';";

    return fileService!.updateFile(
      path: moduleBarrelPath,
      cancelWhen: (content) => content.contains(exportStatement),
      updateLines: (lines) {
        // find the last export statement for features to insert after it
        final insertIndex = lines.lastIndexWhere(
          (line) => line.contains("export 'src/features/"),
        );

        if (insertIndex != -1) {
          lines.insert(insertIndex + 1, exportStatement);
        } else {
          lines.insert(0, exportStatement);
        }
      },
    );
  }

  Future<void> _injectFeatureNotFoundContracts({
    required String moduleName,
    required String featureName,
  }) async {
    final moduleLib = p.join(
      Directory.current.path,
      'modules',
      moduleName,
      'lib',
    );

    final exceptionPath = p.join(
      moduleLib,
      'src',
      'shared',
      'data',
      'errors',
      '${moduleName}_exception.dart',
    );
    final failurePath = p.join(
      moduleLib,
      'src',
      'shared',
      'domain',
      'errors',
      '${moduleName}_failure.dart',
    );
    final failureXPath = p.join(
      moduleLib,
      'src',
      'shared',
      'ui',
      'extensions',
      '${moduleName}_failure_x.dart',
    );

    final injectedException = await _upsertExceptionFeatureNotFound(
      path: exceptionPath,
      moduleName: moduleName,
      featureName: featureName,
    );
    final injectedFailure = await _upsertFailureFeatureNotFound(
      path: failurePath,
      featureName: featureName,
    );
    final injectedFailureX = await _upsertFailureXFeatureNotFound(
      path: failureXPath,
      moduleName: moduleName,
      featureName: featureName,
    );

    if (injectedException || injectedFailure || injectedFailureX) {
      logger.success(
        'Injected "${featureName.camelCase}NotFound" into shared error contracts for module "$moduleName".',
      );
    }
  }

  Future<bool> _upsertExceptionFeatureNotFound({
    required String path,
    required String moduleName,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final modulePascal = moduleName.pascalCase;
    final featureCamel = featureName.camelCase;
    final featurePascal = featureName.pascalCase;
    final featureTitle = featureName.titleCase;

    var source = await file.readAsString();
    final before = source;

    final factorySignature =
        'const factory ${modulePascal}Exception.${featureCamel}NotFound(';
    if (!source.contains(factorySignature)) {
      final factoryBlock =
          '\n  const factory ${modulePascal}Exception.${featureCamel}NotFound({String? msg, StackTrace? st}) =\n'
          '      _${featurePascal}NotFound;\n';

      final anchor = RegExp(r'\n\s*@override').firstMatch(source);
      if (anchor != null) {
        source = source.replaceRange(anchor.start, anchor.start, factoryBlock);
      }
    }

    final messageRegex = RegExp(r'String get message => when\(([\s\S]*?)\);');
    source = source.replaceFirstMapped(messageRegex, (match) {
      final body = match.group(1)!;
      if (body.contains('${featureCamel}NotFound:')) {
        return match.group(0)!;
      }

      final nextBody = _appendWhenCase(
        body: body,
        caseExpression:
            "${featureCamel}NotFound: (msg, _) => msg ?? '$featureTitle not found'",
      );

      return 'String get message => when($nextBody);';
    });

    final toFailureRegex = RegExp(
      r'Failure toFailure\(\) => when\(([\s\S]*?)\);',
    );
    source = source.replaceFirstMapped(toFailureRegex, (match) {
      final body = match.group(1)!;
      if (body.contains('${featureCamel}NotFound:')) {
        return match.group(0)!;
      }

      final nextBody = _appendWhenCase(
        body: body,
        caseExpression:
            '${featureCamel}NotFound: (_, _) => ${modulePascal}Failure.${featureCamel}NotFound',
      );

      return 'Failure toFailure() => when($nextBody);';
    });

    if (source == before) {
      return false;
    }

    await file.writeAsString(source);
    return true;
  }

  Future<bool> _upsertFailureFeatureNotFound({
    required String path,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final caseName = '${featureName.camelCase}NotFound';
    final source = await file.readAsString();
    if (RegExp('\\b${RegExp.escape(caseName)}\\b').hasMatch(source)) {
      return false;
    }

    final enumRegex = RegExp(
      r'(enum\s+[A-Za-z_]\w*\s+implements\s+Failure\s*\{)([\s\S]*?)(\})',
      multiLine: true,
    );
    final match = enumRegex.firstMatch(source);
    if (match == null) return false;

    final body = match.group(2)!;
    final bodyTrimRight = body.trimRight();
    final hasMultilineBody = bodyTrimRight.contains('\n');

    final cases = body
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();

    final insertIndex = cases.isEmpty ? 0 : 1;
    cases.insert(insertIndex, caseName);

    String updatedBody;
    if (hasMultilineBody) {
      final indentMatch = RegExp(r'\n([ \t]*)[A-Za-z_]\w*').firstMatch(body);
      final indent = indentMatch?.group(1) ?? '  ';
      updatedBody = '\n$indent${cases.join(',\n$indent')}\n';
    } else {
      updatedBody = ' ${cases.join(', ')} ';
    }

    final updated = source.replaceRange(
      match.start,
      match.end,
      '${match.group(1)!}$updatedBody${match.group(3)!}',
    );

    await file.writeAsString(updated);
    return true;
  }

  Future<bool> _upsertFailureXFeatureNotFound({
    required String path,
    required String moduleName,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final modulePascal = moduleName.pascalCase;
    final featureCamel = featureName.camelCase;
    final featurePascal = featureName.pascalCase;

    final source = await file.readAsString();
    if (source.contains('${modulePascal}Failure.${featureCamel}NotFound')) {
      return false;
    }

    final switchRegex = RegExp(
      r'return\s+switch\s*\(this\)\s*\{([\s\S]*?)\n([ \t]*)\};',
    );
    final match = switchRegex.firstMatch(source);
    if (match == null) return false;

    final body = match.group(1)!;
    final closingIndent = match.group(2) ?? '    ';

    final indentMatch = RegExp(
      r'\n([ \t]*)[A-Za-z_]\w*Failure\.',
    ).firstMatch(body);
    final indent = indentMatch?.group(1) ?? '      ';

    final line =
        '${modulePascal}Failure.${featureCamel}NotFound => l10n.failure${featurePascal}NotFound,';

    final caseRegex = RegExp(
      r'[A-Za-z_]\w*Failure\.[A-Za-z_]\w*\s*=>\s*[^,]+,',
    );
    final cases = caseRegex
        .allMatches(body)
        .map((entry) => entry.group(0)!.trim())
        .toList();

    final insertIndex = cases.isEmpty ? 0 : 1;
    cases.insert(insertIndex, line);
    final updatedBody = '\n$indent${cases.join('\n$indent')}\n';

    final updated = source.replaceRange(
      match.start,
      match.end,
      'return switch (this) {$updatedBody\n$closingIndent};',
    );

    await file.writeAsString(updated);
    return true;
  }

  String _appendWhenCase({
    required String body,
    required String caseExpression,
  }) {
    final bodyTrimRight = body.trimRight();
    final hasEntries = bodyTrimRight.trim().isNotEmpty;
    if (!hasEntries) {
      return '\n      $caseExpression\n    ';
    }

    final suffix = bodyTrimRight.trim().endsWith(',') ? '' : ',';
    if (!bodyTrimRight.contains('\n')) {
      return '$bodyTrimRight$suffix $caseExpression';
    }

    final indentMatch = RegExp(r'\n([ \t]*)[A-Za-z_]\w*\s*:').firstMatch(body);
    final indent = indentMatch?.group(1) ?? '      ';
    return '$bodyTrimRight$suffix\n$indent$caseExpression';
  }

  Future<bool> _injectArbBoundary({
    required String moduleName,
    required String featureName,
  }) async {
    final l10nDir = Directory(
      p.join(Directory.current.path, 'modules', moduleName, 'lib', 'l10n'),
    );

    if (!await l10nDir.exists()) {
      logger.info(
        'L10n directory not found in module "$moduleName", skipping ARB injection.',
      );
      return false;
    }

    final arbFiles = l10nDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList();

    if (arbFiles.isEmpty) return false;

    final featureCamel = featureName.camelCase;
    final featurePascal = featureName.pascalCase;
    final featureTitle = featureName.titleCase;

    final metaKey = '@${featureCamel}Alt';
    final textKey = '${featureCamel}Alt';
    final failureMetaKey = '@failure${featurePascal}NotFound';
    final failureTextKey = 'failure${featurePascal}NotFound';

    const encoder = JsonEncoder.withIndent('  ');
    var hasAnyInjection = false;

    for (final file in arbFiles) {
      final fileName = p.basename(file.path);
      try {
        final rawJson = await file.readAsString();

        var arbMap = Map<String, dynamic>.from(jsonDecode(rawJson) as Map);
        var didInject = false;

        if (!arbMap.containsKey(metaKey)) {
          arbMap[metaKey] = {
            'description':
                '========================= $featureTitle =========================',
          };
          didInject = true;
        }

        if (!arbMap.containsKey(textKey)) {
          arbMap[textKey] = featureTitle;
          didInject = true;
        }

        if (arbMap.containsKey(failureMetaKey)) {
          arbMap.remove(failureMetaKey);
          didInject = true;
        }

        if (arbMap.containsKey(failureTextKey)) {
          final existingValue = arbMap.remove(failureTextKey);
          arbMap = _insertArbEntryAfterFirstFailure(
            arbMap: arbMap,
            key: failureTextKey,
            value: existingValue,
          );
          didInject = true;
        } else {
          final isIndonesian = fileName.toLowerCase().endsWith('_id.arb');
          arbMap = _insertArbEntryAfterFirstFailure(
            arbMap: arbMap,
            key: failureTextKey,
            value: isIndonesian
                ? '$featureTitle tidak ditemukan'
                : '$featureTitle not found',
          );
          didInject = true;
        }

        if (!didInject) {
          logger.info('ARB keys for "$featureName" already exist in $fileName');
          continue;
        }

        final prettyJson = encoder.convert(arbMap);

        await file.writeAsString('$prettyJson\n');
        logger.success('Injected ARB boundary for "$featureName" to $fileName');
        hasAnyInjection = true;
      } catch (e) {
        logger.error(
          'Failed to inject ARB boundary for "$featureName" in $fileName: $e',
        );
        return false;
      }
    }

    return hasAnyInjection;
  }

  Map<String, dynamic> _insertArbEntryAfterFirstFailure({
    required Map<String, dynamic> arbMap,
    required String key,
    required dynamic value,
  }) {
    final ordered = <String, dynamic>{};
    var inserted = false;

    for (final entry in arbMap.entries) {
      ordered[entry.key] = entry.value;
      if (!inserted && _isFailureMessageArbKey(entry.key)) {
        ordered[key] = value;
        inserted = true;
      }
    }

    if (!inserted) {
      ordered[key] = value;
    }

    return ordered;
  }

  bool _isFailureMessageArbKey(String key) {
    if (key.startsWith('@')) return false;
    return key.startsWith('failure');
  }
}
