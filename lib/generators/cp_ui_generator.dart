import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../services/operation_report_service.dart';
import 'base_generator.dart';

typedef _PlannedCopyFile = ({
  String sourcePath,
  String targetPath,
  String sourceRelativePath,
  String targetRelativePath,
});

class CpUiGenerator
    extends
        BaseGenerator<
          void,
          ({String module, String feature, String fromSlice, String newSlice})
        > {
  const CpUiGenerator({required super.logger});

  @override
  Future<void> generate(
    ({String module, String feature, String fromSlice, String newSlice}) args,
  ) async {
    final moduleName = args.module;
    final featureName = args.feature;
    final fromSlice = args.fromSlice;
    final newSlice = args.newSlice;
    final report = OperationReportService();

    final featureRoot = p.join(
      Directory.current.path,
      'modules',
      moduleName,
      'lib',
      'src',
      'features',
      featureName,
    );

    final featureDir = Directory(featureRoot);
    if (!await featureDir.exists()) {
      logger.error(
        'Feature "$featureName" does not exist in module "$moduleName".',
      );
      exitCode = 1;
      report.logSummary(logger, operationLabel: 'fsda cp-ui');
      return;
    }

    final sourceUiDir = Directory(p.join(featureRoot, 'ui', fromSlice));
    final targetUiDir = Directory(p.join(featureRoot, 'ui', newSlice));

    if (!await sourceUiDir.exists()) {
      logger.error(
        'Source UI slice "$fromSlice" was not found for feature "$featureName".',
      );
      exitCode = 1;
      report.addSkipped(sourceUiDir.path);
      report.logSummary(logger, operationLabel: 'fsda cp-ui');
      return;
    }

    if (await targetUiDir.exists()) {
      logger.error(
        'Target UI slice "$newSlice" already exists. Remove it first before running cp-ui.',
      );
      exitCode = 1;
      report.addSkipped(targetUiDir.path);
      report.logSummary(logger, operationLabel: 'fsda cp-ui');
      return;
    }

    final plannedFiles = <_PlannedCopyFile>[];
    final fileRenameMap = <String, String>{};
    final symbolRenameMap = <String, String>{};

    await for (final entity in sourceUiDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      if (_isGeneratedDartFile(entity.path)) {
        report.addSkipped(entity.path);
        continue;
      }

      final sourceRelativePath = p.relative(
        entity.path,
        from: sourceUiDir.path,
      );
      final targetRelativePath = _renameSliceTokenInPath(
        sourceRelativePath,
        fromSlice: fromSlice,
        newSlice: newSlice,
      );
      final targetPath = p.join(targetUiDir.path, targetRelativePath);

      plannedFiles.add((
        sourcePath: entity.path,
        targetPath: targetPath,
        sourceRelativePath: sourceRelativePath,
        targetRelativePath: targetRelativePath,
      ));

      _registerRenameMaps(
        sourceRelativePath: sourceRelativePath,
        targetRelativePath: targetRelativePath,
        fileRenameMap: fileRenameMap,
        symbolRenameMap: symbolRenameMap,
      );
    }

    if (plannedFiles.isEmpty) {
      logger.error(
        'No eligible UI files found to copy from slice "$fromSlice" (generated files are skipped).',
      );
      exitCode = 1;
      report.logSummary(logger, operationLabel: 'fsda cp-ui');
      return;
    }

    var hasFileConflict = false;
    for (final plannedFile in plannedFiles) {
      final targetFile = File(plannedFile.targetPath);
      if (await targetFile.exists()) {
        hasFileConflict = true;
        report.addSkipped(targetFile.path);
      }
    }

    if (hasFileConflict) {
      logger.error(
        'Target UI files for slice "$newSlice" already exist. Aborting to prevent overwrite.',
      );
      exitCode = 1;
      report.logSummary(logger, operationLabel: 'fsda cp-ui');
      return;
    }

    final sortedFileRenameEntries = fileRenameMap.entries.toList(
      growable: false,
    )..sort((a, b) => b.key.length.compareTo(a.key.length));
    final sortedSymbolRenameEntries = symbolRenameMap.entries.toList(
      growable: false,
    )..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final plannedFile in plannedFiles) {
      final sourceFile = File(plannedFile.sourcePath);
      final targetFile = File(plannedFile.targetPath);
      await targetFile.parent.create(recursive: true);

      if (plannedFile.sourcePath.endsWith('.dart')) {
        var content = await sourceFile.readAsString();
        content = _rewriteUiContent(
          content,
          fromSlice: fromSlice,
          newSlice: newSlice,
          fileRenameEntries: sortedFileRenameEntries,
          symbolRenameEntries: sortedSymbolRenameEntries,
        );
        await targetFile.writeAsString(content);
      } else {
        final bytes = await sourceFile.readAsBytes();
        await targetFile.writeAsBytes(bytes);
      }

      report.addCreated(targetFile.path);
    }

    final featureBarrelChanged = await _duplicateUiExportsInFeatureBarrel(
      featureRoot: featureRoot,
      featureName: featureName,
      fromSlice: fromSlice,
      newSlice: newSlice,
    );

    final featureBarrelPath = p.join(
      featureRoot,
      '${featureName}_feature.dart',
    );
    if (featureBarrelChanged) {
      report.addUpdated(featureBarrelPath);
    } else {
      report.addSkipped(featureBarrelPath);
    }

    logger.success(
      'UI slice "$fromSlice" successfully copied to "$newSlice" in feature "$featureName".',
    );
    report.logSummary(logger, operationLabel: 'fsda cp-ui');
  }

  bool _isGeneratedDartFile(String filePath) {
    return filePath.endsWith('.freezed.dart') || filePath.endsWith('.g.dart');
  }

  void _registerRenameMaps({
    required String sourceRelativePath,
    required String targetRelativePath,
    required Map<String, String> fileRenameMap,
    required Map<String, String> symbolRenameMap,
  }) {
    final sourceFileName = p.basename(sourceRelativePath);
    final targetFileName = p.basename(targetRelativePath);

    if (sourceFileName == targetFileName) {
      return;
    }

    if (!(sourceFileName.endsWith('.dart') &&
        targetFileName.endsWith('.dart'))) {
      return;
    }

    fileRenameMap[sourceFileName] = targetFileName;

    final sourceBaseName = p.basenameWithoutExtension(sourceFileName);
    final targetBaseName = p.basenameWithoutExtension(targetFileName);
    fileRenameMap['$sourceBaseName.freezed.dart'] =
        '$targetBaseName.freezed.dart';
    fileRenameMap['$sourceBaseName.g.dart'] = '$targetBaseName.g.dart';

    final sourceSymbol = sourceBaseName.pascalCase;
    final targetSymbol = targetBaseName.pascalCase;

    if (sourceSymbol != targetSymbol) {
      symbolRenameMap[sourceSymbol] = targetSymbol;
    }
  }

  String _rewriteUiContent(
    String source, {
    required String fromSlice,
    required String newSlice,
    required List<MapEntry<String, String>> fileRenameEntries,
    required List<MapEntry<String, String>> symbolRenameEntries,
  }) {
    var rewritten = source;

    rewritten = rewritten
        .replaceAll('ui/$fromSlice/', 'ui/$newSlice/')
        .replaceAll('ui\\$fromSlice\\', 'ui\\$newSlice\\');

    for (final entry in fileRenameEntries) {
      rewritten = rewritten.replaceAll(entry.key, entry.value);
    }

    for (final entry in symbolRenameEntries) {
      rewritten = rewritten.replaceAll(entry.key, entry.value);
    }

    return rewritten;
  }

  Future<bool> _duplicateUiExportsInFeatureBarrel({
    required String featureRoot,
    required String featureName,
    required String fromSlice,
    required String newSlice,
  }) async {
    final featureBarrelFile = File(
      p.join(featureRoot, '${featureName}_feature.dart'),
    );
    if (!await featureBarrelFile.exists()) {
      return false;
    }

    final lines = await featureBarrelFile.readAsLines();
    final existingTrimmedLines = lines.map((line) => line.trim()).toSet();
    final nextLines = <String>[];

    var changed = false;
    for (final line in lines) {
      nextLines.add(line);
      final trimmed = line.trim();
      final isUiExport = trimmed.startsWith("export 'ui/$fromSlice/");

      if (!isUiExport) {
        continue;
      }

      final replacedLine = _renameSliceTokenInPath(
        line,
        fromSlice: fromSlice,
        newSlice: newSlice,
      );
      final replacedTrimmedLine = replacedLine.trim();

      if (replacedTrimmedLine == trimmed) {
        continue;
      }

      if (existingTrimmedLines.contains(replacedTrimmedLine)) {
        continue;
      }

      nextLines.add(replacedLine);
      existingTrimmedLines.add(replacedTrimmedLine);
      changed = true;
    }

    if (!changed) {
      return false;
    }

    await featureBarrelFile.writeAsString(
      '${nextLines.join('\n').trimRight()}\n',
    );
    return true;
  }

  String _renameSliceTokenInPath(
    String source, {
    required String fromSlice,
    required String newSlice,
  }) {
    final escapedFromSlice = RegExp.escape(fromSlice);

    return source.replaceAllMapped(
      RegExp('(^|[^a-z0-9])$escapedFromSlice(?=[^a-z0-9]|\$)'),
      (match) => '${match.group(1) ?? ''}$newSlice',
    );
  }
}
