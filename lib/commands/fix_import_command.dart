import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../constants/cli_rules.dart';
import '../services/logger_service.dart';
import '../services/workspace_service.dart';

class FixImportCommand extends Command<void> {
  final WorkspaceService workspaceService;
  final LoggerService logger;
  static const _layerOrder = <String>['data', 'domain', 'logic', 'ui'];

  FixImportCommand({required this.workspaceService, required this.logger}) {
    argParser
      ..addOption('module', abbr: 'm', help: 'Target module name.')
      ..addOption('app', abbr: 'a', help: 'Target app name.');
  }

  @override
  final String name = 'fix-import';

  @override
  final String description =
      'Auto-fix imports via dart fix and normalize feature barrel exports by layer markers.';

  @override
  String get invocation => 'fsda fix-import [-m <module>] [-a <app>]';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;
    if (args.isNotEmpty) {
      throw UsageException(
        'Unexpected argument(s): "${args.join(' ')}". This command only accepts options.',
        usage,
      );
    }

    final module = (argResults?['module'] as String?)?.trim();
    final app = (argResults?['app'] as String?)?.trim();

    if ((module == null || module.isEmpty) && (app == null || app.isEmpty)) {
      throw UsageException(
        'At least one target is required: --module (-m) or --app (-a).',
        usage,
      );
    }

    final targets = <({String label, String path})>[];

    if (module != null && module.isNotEmpty) {
      final moduleNameRegExp = RegExp(CliRules.moduleNamePattern);
      if (!moduleNameRegExp.hasMatch(module)) {
        throw UsageException(
          'Invalid module name "$module".\n${CliRules.moduleNameRule}',
          usage,
        );
      }

      final modulePath = p.join(Directory.current.path, 'modules', module);
      if (!Directory(modulePath).existsSync()) {
        throw UsageException('Module "$module" does not exist.', usage);
      }

      targets.add((label: 'module/$module', path: modulePath));
    }

    if (app != null && app.isNotEmpty) {
      final appNameRegExp = RegExp(CliRules.appNamePattern);
      if (!appNameRegExp.hasMatch(app)) {
        throw UsageException(
          'Invalid app name "$app".\n${CliRules.appNameRule}',
          usage,
        );
      }

      final appPath = p.join(Directory.current.path, 'apps', app);
      if (!Directory(appPath).existsSync()) {
        throw UsageException('App "$app" does not exist.', usage);
      }

      targets.add((label: 'app/$app', path: appPath));
    }

    for (final target in targets) {
      logger.info('Applying import fixes for ${target.label}...');
      final result = await Process.run(
        'dart',
        const [
          'fix',
          '--apply',
          '--code=directives_ordering',
          '--code=unused_import',
        ],
        workingDirectory: target.path,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        final error = (result.stderr ?? '').toString().trim();
        throw Exception(
          error.isEmpty
              ? 'Failed to apply import fixes for ${target.label}.'
              : 'Failed to apply import fixes for ${target.label}: $error',
        );
      }

      logger.success('Import fixes applied for ${target.label}.');

      final normalizedBarrels = await _normalizeFeatureBarrels(target.path);
      if (normalizedBarrels.isEmpty) {
        logger.info(
          'No feature barrel export reordering needed for ${target.label}.',
        );
      } else {
        logger.success(
          'Reordered ${normalizedBarrels.length} feature barrel file(s) for ${target.label}.',
        );
        for (final barrelPath in normalizedBarrels) {
          final relativePath = p
              .relative(barrelPath, from: target.path)
              .replaceAll('\\', '/');
          logger.info('  normalized: $relativePath');
        }
      }
    }

    logger.success('fix-import completed for ${targets.length} target(s).');
  }

  Future<List<String>> _normalizeFeatureBarrels(String targetPath) async {
    final barrelPaths = await _collectFeatureBarrelPaths(targetPath);
    final touched = <String>[];

    for (final barrelPath in barrelPaths) {
      final changed = await _reorderFeatureBarrel(barrelPath);
      if (changed) {
        touched.add(barrelPath);
      }
    }

    return touched;
  }

  Future<List<String>> _collectFeatureBarrelPaths(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      return const <String>[];
    }

    final paths = <String>[];
    await for (final entity in rootDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('_feature.dart')) continue;
      paths.add(entity.path);
    }

    paths.sort();
    return paths;
  }

  Future<bool> _reorderFeatureBarrel(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return false;
    }

    final source = await file.readAsString();
    final normalizedSource = '${source.replaceAll('\r\n', '\n').trimRight()}\n';
    final rebuilt = _rebuildFeatureBarrel(normalizedSource);

    if (rebuilt == null || rebuilt == normalizedSource) {
      return false;
    }

    await file.writeAsString(rebuilt);
    return true;
  }

  String? _rebuildFeatureBarrel(String source) {
    final lines = source.split('\n');
    final markerIndexes = <String, int>{};

    for (var index = 0; index < lines.length; index++) {
      final trimmed = lines[index].trim();
      for (final layer in _layerOrder) {
        if (trimmed != '// $layer') continue;
        if (markerIndexes.containsKey(layer)) {
          return null;
        }
        markerIndexes[layer] = index;
      }
    }

    if (markerIndexes.length != _layerOrder.length) {
      return null;
    }

    var previousIndex = -1;
    for (final layer in _layerOrder) {
      final markerIndex = markerIndexes[layer]!;
      if (markerIndex <= previousIndex) {
        return null;
      }
      previousIndex = markerIndex;
    }

    final firstMarkerIndex = markerIndexes[_layerOrder.first]!;
    final lastMarkerIndex = markerIndexes[_layerOrder.last]!;

    final exportPattern = RegExp(r"^(\s*)export\s+'([^']+)';\s*$");
    String exportIndent = '';

    for (var index = firstMarkerIndex; index <= lastMarkerIndex; index++) {
      final line = lines[index];
      final trimmed = line.trim();

      if (trimmed.isEmpty || _isLayerMarker(trimmed)) {
        continue;
      }

      final exportMatch = exportPattern.firstMatch(line);
      if (exportMatch == null) {
        return null;
      }

      exportIndent = exportIndent.isEmpty
          ? (exportMatch.group(1) ?? '')
          : exportIndent;
    }

    final exportsByLayer = <String, Set<String>>{
      for (final layer in _layerOrder) layer: <String>{},
    };

    for (final line in lines) {
      final exportMatch = exportPattern.firstMatch(line);
      if (exportMatch == null) continue;

      exportIndent = exportIndent.isEmpty
          ? (exportMatch.group(1) ?? '')
          : exportIndent;

      final exportPath = exportMatch.group(2)!;
      final layer = _resolveLayerFromExportPath(exportPath);
      if (layer == null) {
        return null;
      }

      exportsByLayer[layer]!.add("export '$exportPath';");
    }

    final prefix = lines
        .sublist(0, firstMarkerIndex)
        .where((line) => !exportPattern.hasMatch(line))
        .toList();

    final suffix = lines
        .sublist(lastMarkerIndex + 1)
        .where((line) => !exportPattern.hasMatch(line))
        .toList();

    final markerIndent = _leadingWhitespace(lines[firstMarkerIndex]);
    final rebuiltLines = <String>[...prefix];

    if (rebuiltLines.isNotEmpty && rebuiltLines.last.trim().isNotEmpty) {
      rebuiltLines.add('');
    }

    for (var index = 0; index < _layerOrder.length; index++) {
      final layer = _layerOrder[index];
      rebuiltLines.add('$markerIndent// $layer');

      final sortedExports = exportsByLayer[layer]!.toList()..sort();
      rebuiltLines.addAll(sortedExports.map((line) => '$exportIndent$line'));

      if (index < _layerOrder.length - 1) {
        rebuiltLines.add('');
      }
    }

    final trailingSuffix = [...suffix];
    while (trailingSuffix.isNotEmpty && trailingSuffix.first.trim().isEmpty) {
      trailingSuffix.removeAt(0);
    }

    if (trailingSuffix.isNotEmpty) {
      rebuiltLines.add('');
      rebuiltLines.addAll(trailingSuffix);
    }

    final rebuilt = rebuiltLines
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trimRight();

    return '$rebuilt\n';
  }

  bool _isLayerMarker(String trimmedLine) {
    return _layerOrder.any((layer) => trimmedLine == '// $layer');
  }

  String _leadingWhitespace(String line) {
    return RegExp(r'^\s*').stringMatch(line) ?? '';
  }

  String? _resolveLayerFromExportPath(String exportPath) {
    for (final layer in _layerOrder) {
      if (exportPath.startsWith('$layer/')) {
        return layer;
      }
    }

    return null;
  }
}
