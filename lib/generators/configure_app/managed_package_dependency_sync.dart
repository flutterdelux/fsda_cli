typedef ManagedPackageSyncResult = ({
  List<String> updatedLines,
  List<String> added,
  List<String> removed,
});

class ManagedPackageDependencySync {
  const ManagedPackageDependencySync();

  ManagedPackageSyncResult sync({
    required List<String> lines,
    required Set<String> managedPackagesToKeep,
    required Set<String> managedPackagesToRemove,
  }) {
    final dependenciesStart = lines.indexWhere(
      (line) => line.trim() == 'dependencies:',
    );

    if (dependenciesStart == -1) {
      final updatedLines = <String>[...lines];
      final insertIndex =
          findTopLevelKeyIndex(updatedLines, 'dev_dependencies') ??
          updatedLines.length;

      final added = managedPackagesToKeep.toList()..sort();
      const dependencyIndent = 2;
      final dependencyBlock = <String>['dependencies:'];
      for (final packageName in added) {
        dependencyBlock.add('${_indent(dependencyIndent)}$packageName:');
        dependencyBlock.add(
          '${_indent(dependencyIndent + 2)}path: ../../packages/$packageName',
        );
      }
      dependencyBlock.add('');

      updatedLines.insertAll(insertIndex, dependencyBlock);
      return (
        updatedLines: updatedLines,
        added: added,
        removed: const <String>[],
      );
    }

    final dependenciesEnd = findDependenciesSectionEnd(
      lines,
      dependenciesStart,
    );
    final dependencyIndent =
        detectDependencyIndent(lines, dependenciesStart, dependenciesEnd) ?? 2;

    final rebuiltSection = <String>[];

    final existingManagedPackages = <String>{};
    final seenManagedKept = <String>{};
    final removedPackages = <String>[];

    var i = dependenciesStart + 1;
    while (i < dependenciesEnd) {
      final key = extractDependencyKey(lines[i], dependencyIndent);
      if (key == null) {
        rebuiltSection.add(lines[i]);
        i += 1;
        continue;
      }

      var blockEnd = i + 1;
      while (blockEnd < dependenciesEnd) {
        final nextKey = extractDependencyKey(lines[blockEnd], dependencyIndent);
        if (nextKey != null) break;
        blockEnd += 1;
      }

      if (managedPackagesToRemove.contains(key)) {
        if (!removedPackages.contains(key)) {
          removedPackages.add(key);
        }
        i = blockEnd;
        continue;
      }

      if (managedPackagesToKeep.contains(key) &&
          seenManagedKept.contains(key)) {
        i = blockEnd;
        continue;
      }

      rebuiltSection.addAll(lines.sublist(i, blockEnd));
      if (managedPackagesToKeep.contains(key)) {
        seenManagedKept.add(key);
        existingManagedPackages.add(key);
      }
      i = blockEnd;
    }

    final missingPackages =
        managedPackagesToKeep.difference(existingManagedPackages).toList()
          ..sort();

    for (final packageName in missingPackages) {
      rebuiltSection.add('${_indent(dependencyIndent)}$packageName:');
      rebuiltSection.add(
        '${_indent(dependencyIndent + 2)}path: ../../packages/$packageName',
      );
    }

    final updatedLines = <String>[
      ...lines.sublist(0, dependenciesStart + 1),
      ...rebuiltSection,
      ...lines.sublist(dependenciesEnd),
    ];

    removedPackages.sort();
    return (
      updatedLines: updatedLines,
      added: missingPackages,
      removed: removedPackages,
    );
  }

  int findDependenciesSectionEnd(List<String> lines, int dependenciesStart) {
    var index = dependenciesStart + 1;
    while (index < lines.length) {
      final line = lines[index];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        index += 1;
        continue;
      }

      final isTopLevelKey = RegExp(
        r'^[a-zA-Z_][a-zA-Z0-9_]*:\s*$',
      ).hasMatch(line);
      if (isTopLevelKey) {
        return index;
      }

      index += 1;
    }

    return lines.length;
  }

  int? findTopLevelKeyIndex(List<String> lines, String keyName) {
    final key = '$keyName:';
    final index = lines.indexWhere(
      (line) => !line.startsWith(' ') && line.trim() == key,
    );
    return index == -1 ? null : index;
  }

  int? detectDependencyIndent(
    List<String> lines,
    int dependenciesStart,
    int dependenciesEnd,
  ) {
    for (var i = dependenciesStart + 1; i < dependenciesEnd; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      final match = RegExp(r'^(\s+)([a-zA-Z0-9_-]+):').firstMatch(line);
      if (match == null) continue;

      return match.group(1)?.length;
    }

    return null;
  }

  String? extractDependencyKey(String line, int indent) {
    final prefix = _indent(indent);
    final match = RegExp(
      '^${RegExp.escape(prefix)}([a-zA-Z0-9_-]+):',
    ).firstMatch(line);
    if (match == null) return null;

    final key = match.group(1);
    if (key == null || key.isEmpty) return null;
    return key;
  }

  String _indent(int spaces) {
    return ' ' * spaces;
  }
}
