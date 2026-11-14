import 'dart:collection';

abstract final class OperationReportTemplate {
  static const _doubleDivider =
      '============================================================';
  static const _divider =
      '------------------------------------------------------------';

  static StringBuffer build({
    required String operationLabel,
    required SplayTreeSet<String> createdPaths,
    required SplayTreeSet<String> injectedPaths,
    required SplayTreeSet<String> unjectedPaths,
    required SplayTreeSet<String> removedPaths,
    required SplayTreeSet<String> skippedPaths,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(_doubleDivider);
    buffer.writeln('$operationLabel:');
    buffer.writeln(_doubleDivider);

    final hasAnyChange =
        createdPaths.isNotEmpty ||
        injectedPaths.isNotEmpty ||
        unjectedPaths.isNotEmpty ||
        removedPaths.isNotEmpty;

    if (!hasAnyChange && skippedPaths.isEmpty) {
      buffer.writeln('- no file change detected');
      buffer.writeln(_divider);
      return buffer;
    }

    _appendSection(buffer, label: '✨ Created', paths: createdPaths);
    _appendSection(buffer, label: '💉 Injected', paths: injectedPaths);
    _appendSection(buffer, label: '🧪 Unjected', paths: unjectedPaths);
    _appendSection(buffer, label: '🗑️ Removed', paths: removedPaths);
    _appendSection(buffer, label: '⏭️ Skipped', paths: skippedPaths);

    buffer.writeln(_divider);
    return buffer;
  }

  static StringBuffer buildConfigure({
    required String operationLabel,
    required SplayTreeSet<String> addedPackages,
    required SplayTreeSet<String> removedPackages,
    required SplayTreeSet<String> retainedPackages,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(_doubleDivider);
    buffer.writeln('$operationLabel:');
    buffer.writeln(_doubleDivider);

    final hasAnyChange =
        addedPackages.isNotEmpty ||
        removedPackages.isNotEmpty ||
        retainedPackages.isNotEmpty;

    if (!hasAnyChange) {
      buffer.writeln('- no package change detected');
      buffer.writeln(_divider);
      return buffer;
    }

    _appendSection(buffer, label: '✨ Added', paths: addedPackages);
    _appendSection(buffer, label: '🗑️ Removed', paths: removedPackages);
    _appendSection(buffer, label: '🛡️ Retained', paths: retainedPackages);

    buffer.writeln(_divider);
    return buffer;
  }

  static void _appendSection(
    StringBuffer buffer, {
    required String label,
    required SplayTreeSet<String> paths,
  }) {
    if (paths.isEmpty) return;

    buffer.writeln('$label (${paths.length})');
    for (final path in paths) {
      buffer.writeln('   $path');
    }
  }
}
