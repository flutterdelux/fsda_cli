import 'package:yaml/yaml.dart';

import '../../services/process_service.dart';

class AppDependencyInstaller {
  final ProcessService processService;

  const AppDependencyInstaller({required this.processService});

  Future<List<String>> addMissingDependencies({
    required String appPath,
    required List<String> pubspecLines,
    required Set<String> desiredDependencies,
  }) async {
    if (desiredDependencies.isEmpty) {
      return const <String>[];
    }

    final dependencyValueMap = _extractDependencyValueMap(pubspecLines);
    final dependenciesToInstall = desiredDependencies.where((dependency) {
      if (!dependencyValueMap.containsKey(dependency)) return true;

      final value = dependencyValueMap[dependency]?.trim().toLowerCase();
      if (value == null || value.isEmpty) return true;
      if (value == 'any' || value == 'null') return true;
      if (value.startsWith('{') && value.endsWith('}')) return false;

      return false;
    }).toList()..sort();

    if (dependenciesToInstall.isEmpty) {
      return const <String>[];
    }

    await processService.run(
      label: 'Add App Dependencies',
      executable: 'dart',
      arguments: ['pub', 'add', ...dependenciesToInstall],
      workingDirectory: appPath,
      timeout: const Duration(minutes: 2),
    );

    return dependenciesToInstall;
  }

  Map<String, String> _extractDependencyValueMap(List<String> pubspecLines) {
    final raw = pubspecLines.join('\n');
    final parsed = loadYaml(raw);

    if (parsed is! YamlMap) {
      return <String, String>{};
    }

    final dependencies = parsed['dependencies'];
    if (dependencies is! YamlMap) {
      return <String, String>{};
    }

    final result = <String, String>{};
    for (final entry in dependencies.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty) continue;

      final value = entry.value.toString().trim();
      result[key] = value;
    }

    return result;
  }
}
