import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../logger_service.dart';

class ArbInjectorService {
  const ArbInjectorService({required this.logger});

  final LoggerService logger;

  Future<Set<String>> injectEntries({
    required String moduleName,
    required Map<String, dynamic> entries,
    required String contextLabel,
  }) async {
    final touchedPaths = <String>{};
    if (entries.isEmpty) {
      return touchedPaths;
    }

    final l10nDir = Directory(
      p.join(Directory.current.path, 'modules', moduleName, 'lib', 'l10n'),
    );

    if (!await l10nDir.exists()) {
      logger.info(
        'L10n directory not found in module "$moduleName", skipping ARB injection for "$contextLabel".',
      );
      return touchedPaths;
    }

    final arbFiles = l10nDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList(growable: false);

    if (arbFiles.isEmpty) {
      logger.info(
        'No .arb files found in module "$moduleName", skipping ARB injection for "$contextLabel".',
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

      var arbMap = Map<String, dynamic>.from(decoded);
      var added = 0;

      for (final entry in entries.entries) {
        if (arbMap.containsKey(entry.key)) {
          continue;
        }

        arbMap = _insertArbEntry(
          source: arbMap,
          key: entry.key,
          value: entry.value,
        );
        added += 1;
      }

      if (added == 0) {
        continue;
      }

      await arbFile.writeAsString('${encoder.convert(arbMap)}\n');
      touchedPaths.add(arbFile.path);
      logger.success(
        'Injected $added ARB entr${added == 1 ? 'y' : 'ies'} into ${p.basename(arbFile.path)} for "$contextLabel".',
      );
    }

    if (touchedPaths.isEmpty) {
      logger.info(
        'ARB entries for "$contextLabel" already exist in all module .arb files for "$moduleName".',
      );
    }

    return touchedPaths;
  }

  Map<String, dynamic> _insertArbEntry({
    required Map<String, dynamic> source,
    required String key,
    required dynamic value,
  }) {
    if (!_isFailureFamilyKey(key)) {
      source[key] = value;
      return source;
    }

    final hasFailureSection = source.keys.any(_isFailureFamilyKey);
    if (!hasFailureSection) {
      return _insertFailureAfterLocaleSection(
        source: source,
        key: key,
        value: value,
      );
    }

    final ordered = <String, dynamic>{};
    var inserted = false;
    var inFailureSection = false;

    for (final entry in source.entries) {
      final currentIsFailure = _isFailureFamilyKey(entry.key);
      if (currentIsFailure) {
        inFailureSection = true;
        ordered[entry.key] = entry.value;
        continue;
      }

      if (inFailureSection && !inserted) {
        ordered[key] = value;
        inserted = true;
      }

      ordered[entry.key] = entry.value;
    }

    if (!inserted) {
      ordered[key] = value;
    }

    return ordered;
  }

  Map<String, dynamic> _insertFailureAfterLocaleSection({
    required Map<String, dynamic> source,
    required String key,
    required dynamic value,
  }) {
    final ordered = <String, dynamic>{};
    var inserted = false;

    for (final entry in source.entries) {
      if (!inserted && !_isLocaleHeaderKey(entry.key)) {
        ordered[key] = value;
        inserted = true;
      }

      ordered[entry.key] = entry.value;
    }

    if (!inserted) {
      ordered[key] = value;
    }

    return ordered;
  }

  bool _isFailureFamilyKey(String key) {
    return key.startsWith('failure') || key.startsWith('@failure');
  }

  bool _isLocaleHeaderKey(String key) {
    return key.startsWith('@@');
  }
}
