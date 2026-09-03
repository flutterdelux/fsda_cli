import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'logger_service.dart';

class OperationReportService {
  final SplayTreeSet<String> _createdPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _injectedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _updatedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _removedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _skippedPaths = SplayTreeSet<String>();

  void addCreated(String path) {
    _createdPaths.add(_normalizePath(path));
  }

  void addInjected(String path) {
    _injectedPaths.add(_normalizePath(path));
  }

  void addUpdated(String path) {
    _updatedPaths.add(_normalizePath(path));
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
      _updatedPaths.isNotEmpty ||
      _removedPaths.isNotEmpty;

  void logSummary(LoggerService logger, {required String operationLabel}) {
    logger.info('Affected paths for $operationLabel:');

    if (!hasAnyChange && _skippedPaths.isEmpty) {
      logger.log('- no file change detected');
      return;
    }

    _logSection(logger, label: 'created', paths: _createdPaths);
    _logSection(logger, label: 'injected', paths: _injectedPaths);
    _logSection(logger, label: 'updated', paths: _updatedPaths);
    _logSection(logger, label: 'removed', paths: _removedPaths);
    _logSection(logger, label: 'skipped', paths: _skippedPaths);
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
    final normalized = p.normalize(path);

    if (p.isAbsolute(normalized)) {
      return p
          .relative(normalized, from: Directory.current.path)
          .replaceAll('\\', '/');
    }

    return normalized.replaceAll('\\', '/');
  }
}
