import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'logger_service.dart';

class OperationReportService {
  static const _doubleDivider =
      '============================================================';
  static const _divider =
      '------------------------------------------------------------';

  final SplayTreeSet<String> _createdPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _injectedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _removedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _skippedPaths = SplayTreeSet<String>();
  var _operationDepth = 0;

  void beginOperation() {
    if (_operationDepth == 0) {
      clear();
    }
    _operationDepth++;
  }

  void endOperation(LoggerService logger, {required String operationLabel}) {
    if (_operationDepth == 0) return;
    _operationDepth--;
    if (_operationDepth == 0) {
      _writeSummary(logger, operationLabel: operationLabel);
      clear();
    }
  }

  void addCreated(String path) {
    _createdPaths.add(_normalizePath(path));
  }

  void addInjected(String path) {
    _injectedPaths.add(_normalizePath(path));
  }

  void addUpdated(String path) {
    // We treat updated and injected as the same reporting category.
    addInjected(path);
  }

  void addRemoved(String path) {
    _removedPaths.add(_normalizePath(path));
  }

  void addSkipped(String path) {
    _skippedPaths.add(_normalizePath(path));
  }

  void addCreatedTemplateFiles({
    required String targetRoot,
    required Iterable<String> relativeFiles,
  }) {
    for (final relativeFile in relativeFiles) {
      addCreated(p.join(targetRoot, relativeFile));
    }
  }

  void addSkippedTemplateFiles({
    required String targetRoot,
    required Iterable<String> relativeFiles,
  }) {
    for (final relativeFile in relativeFiles) {
      addSkipped(p.join(targetRoot, relativeFile));
    }
  }

  bool get hasAnyChange =>
      _createdPaths.isNotEmpty ||
      _injectedPaths.isNotEmpty ||
      _removedPaths.isNotEmpty;

  void logSummary(LoggerService logger, {required String operationLabel}) {
    if (_operationDepth > 0) return;
    _writeSummary(logger, operationLabel: operationLabel);
    clear();
  }

  void _writeSummary(LoggerService logger, {required String operationLabel}) {
    logger.log(_doubleDivider);
    logger.info('$operationLabel:');
    logger.log(_doubleDivider);

    if (!hasAnyChange && _skippedPaths.isEmpty) {
      logger.log('- no file change detected');
      logger.log(_divider);
      return;
    }

    _logSection(logger, label: '✨ Created', paths: _createdPaths);
    _logSection(logger, label: '💉 Injected', paths: _injectedPaths);
    _logSection(logger, label: '🗑️ Removed', paths: _removedPaths);
    _logSection(logger, label: '⏩ Skipped', paths: _skippedPaths);
    logger.log(_divider);
  }

  void clear() {
    _createdPaths.clear();
    _injectedPaths.clear();
    _removedPaths.clear();
    _skippedPaths.clear();
  }

  void _logSection(
    LoggerService logger, {
    required String label,
    required SplayTreeSet<String> paths,
  }) {
    if (paths.isEmpty) {
      return;
    }

    logger.log('- $label (${paths.length})');
    for (final path in paths) {
      logger.log('  $path');
    }
  }

  String _normalizePath(String path) {
    var normalized = p.normalize(path);

    // .gitkeep is implementation detail; surface its parent folder instead.
    if (p.basename(normalized) == '.gitkeep') {
      normalized = p.dirname(normalized);
    }

    if (p.isAbsolute(normalized)) {
      return p
          .relative(normalized, from: Directory.current.path)
          .replaceAll('\\', '/');
    }

    return normalized.replaceAll('\\', '/');
  }
}
