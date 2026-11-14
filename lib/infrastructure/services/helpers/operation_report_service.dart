import 'dart:collection';
import 'package:path/path.dart' as p;

import '../../templates/operation_report_template.dart';
import 'directory_service.dart';

class OperationReportService {
  final DirectoryService _directoryService;

  final _createdPaths = SplayTreeSet<String>();
  final _injectedPaths = SplayTreeSet<String>();
  final _unjectedPaths = SplayTreeSet<String>();
  final _removedPaths = SplayTreeSet<String>();
  final _skippedPaths = SplayTreeSet<String>();

  final _addedPackages = SplayTreeSet<String>();
  final _removedPackages = SplayTreeSet<String>();
  final _retainedPackages = SplayTreeSet<String>();

  OperationReportService({required DirectoryService directoryService})
    : _directoryService = directoryService;

  void addCreated(String path) => _createdPaths.add(_normalizePath(path));
  void addInjected(String path) => _injectedPaths.add(_normalizePath(path));
  void addUnjected(String path) => _unjectedPaths.add(_normalizePath(path));
  void addRemoved(String path) => _removedPaths.add(_normalizePath(path));
  void addSkipped(String path) => _skippedPaths.add(_normalizePath(path));

  void addAddedPackages(String path) =>
      _addedPackages.add(_normalizePath(path));
  void addRemovedPackages(String path) =>
      _removedPackages.add(_normalizePath(path));
  void addRetainedPackages(String path) =>
      _retainedPackages.add(_normalizePath(path));

  StringBuffer generateReport({required String operationLabel}) {
    final reportBuffer = OperationReportTemplate.build(
      operationLabel: operationLabel,
      createdPaths: _createdPaths,
      injectedPaths: _injectedPaths,
      unjectedPaths: _unjectedPaths,
      removedPaths: _removedPaths,
      skippedPaths: _skippedPaths,
    );

    clear();
    return reportBuffer;
  }

  StringBuffer generatePackageReport({required String operationLabel}) {
    final reportBuffer = OperationReportTemplate.buildConfigure(
      operationLabel: operationLabel,
      addedPackages: _addedPackages,
      removedPackages: _removedPackages,
      retainedPackages: _retainedPackages,
    );

    clear();
    return reportBuffer;
  }

  void clear() {
    _createdPaths.clear();
    _injectedPaths.clear();
    _removedPaths.clear();
    _skippedPaths.clear();

    _addedPackages.clear();
    _removedPackages.clear();
    _retainedPackages.clear();
  }

  String _normalizePath(String path) {
    var normalized = p.normalize(path);

    // Tangani detail implementasi khusus (misal .gitkeep atau ekstensi generated file)
    if (p.basename(normalized) == '.gitkeep') {
      normalized = p.dirname(normalized);
    }

    // Ubah absolute path menjadi relative path terhadap direktori aktif
    if (p.isAbsolute(normalized)) {
      normalized = p.relative(normalized, from: _directoryService.currentPath);
    }

    // Pastikan konsisten menggunakan forward slash (/) lintas platform
    return normalized.replaceAll('\\', '/');
  }
}
