import 'dart:collection';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../templates/operation_report_template.dart';

class OperationReportService {
  final SplayTreeSet<String> _createdPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _injectedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _removedPaths = SplayTreeSet<String>();
  final SplayTreeSet<String> _skippedPaths = SplayTreeSet<String>();

  void addCreated(String path) => _createdPaths.add(_normalizePath(path));
  void addInjected(String path) => _injectedPaths.add(_normalizePath(path));
  void addRemoved(String path) => _removedPaths.add(_normalizePath(path));
  void addSkipped(String path) => _skippedPaths.add(_normalizePath(path));

  StringBuffer generateReport({required String operationLabel}) {
    final reportBuffer = OperationReportTemplate.build(
      operationLabel: operationLabel,
      createdPaths: _createdPaths,
      injectedPaths: _injectedPaths,
      removedPaths: _removedPaths,
      skippedPaths: _skippedPaths,
    );

    clear();
    return reportBuffer;
  }

  void clear() {
    _createdPaths.clear();
    _injectedPaths.clear();
    _removedPaths.clear();
    _skippedPaths.clear();
  }

  String _normalizePath(String path) {
    var normalized = p.normalize(path);

    // Tangani detail implementasi khusus (misal .gitkeep atau ekstensi generated file)
    if (p.basename(normalized) == '.gitkeep') {
      normalized = p.dirname(normalized);
    }

    // Ubah absolute path menjadi relative path terhadap direktori aktif
    if (p.isAbsolute(normalized)) {
      normalized = p.relative(normalized, from: Directory.current.path);
    }

    // Pastikan konsisten menggunakan forward slash (/) lintas platform
    return normalized.replaceAll('\\', '/');
  }
}
