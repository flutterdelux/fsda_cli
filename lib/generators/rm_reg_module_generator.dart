import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../generated/bricks/reg_module_bundle.dart';
import '../services/memory_generator_target.dart';
import 'base_generator.dart';

class RmRegModuleGenerator
    extends BaseGenerator<void, ({String app, String module})> {
  RmRegModuleGenerator({required super.logger, required super.fileService});

  @override
  Future<void> generate(({String app, String module}) arg) async {
    final appName = arg.app;
    final moduleName = arg.module;

    logger.info(
      'Removing module "$moduleName" registration from "$appName"...',
    );

    final manifest = await _loadRegManifest(
      appName: appName,
      moduleName: moduleName,
    );
    if (manifest == null) {
      logger.error(
        'Failed to resolve reg.yaml manifest for module "$moduleName".',
      );
      return;
    }

    await _removeDependency(appName: appName, moduleName: moduleName);

    await _removeInjection(manifest['di'] as YamlMap?);
    await _removeInjection(manifest['route'] as YamlMap?);
    await _removeInjection(manifest['l10n'] as YamlMap?);
    await _removeInjection(manifest['failure_x'] as YamlMap?);

    final wrapperDir = Directory(
      p.join(
        Directory.current.path,
        'apps',
        appName,
        'lib',
        'modules',
        moduleName,
      ),
    );
    if (await wrapperDir.exists()) {
      await wrapperDir.delete(recursive: true);
      logger.info(
        'Removed wrapper directory: apps/$appName/lib/modules/$moduleName',
      );
    }

    logger.success('Module "$moduleName" unregistered from "$appName".');
  }

  Future<YamlMap?> _loadRegManifest({
    required String appName,
    required String moduleName,
  }) async {
    final memoryTarget = MemoryGeneratorTarget();
    final generator = await MasonGenerator.fromBundle(regModuleBundle);

    await generator.generate(
      memoryTarget,
      vars: <String, dynamic>{'app': appName, 'module': moduleName},
    );

    for (final entry in memoryTarget.files.entries) {
      final fileName = p.basename(entry.key);
      if (fileName != 'reg.yaml') continue;

      final raw = utf8.decode(entry.value);
      return loadYaml(raw) as YamlMap;
    }

    return null;
  }

  Future<void> _removeDependency({
    required String appName,
    required String moduleName,
  }) async {
    final pubspecFile = File(
      p.join(Directory.current.path, 'apps', appName, 'pubspec.yaml'),
    );

    if (!await pubspecFile.exists()) {
      logger.error('pubspec.yaml not found for app "$appName".');
      return;
    }

    final lines = await pubspecFile.readAsLines();
    final updatedLines = <String>[];

    var removed = false;
    for (var i = 0; i < lines.length; i++) {
      final current = lines[i];
      final next = i + 1 < lines.length ? lines[i + 1] : '';
      final isModuleKey = RegExp(
        r'^\s*' + RegExp.escape(moduleName) + r':\s*$',
      ).hasMatch(current);
      final isModulePath = next.contains('../../modules/$moduleName');

      if (isModuleKey && isModulePath) {
        removed = true;
        i += 1;
        continue;
      }

      updatedLines.add(current);
    }

    if (removed) {
      await pubspecFile.writeAsString('${updatedLines.join('\n')}\n');
      logger.info('Removed pubspec dependency for "$moduleName".');
    }
  }

  Future<void> _removeInjection(YamlMap? yamlRaw) async {
    final path = yamlRaw?['path'] as String?;
    final imports = yamlRaw?['imports'] as YamlList?;
    final code = yamlRaw?['code'] as String?;

    if (path == null) return;

    final file = File(path);
    if (!await file.exists()) return;

    var source = await file.readAsString();

    if (imports != null) {
      for (final item in imports) {
        final importLine = item.toString();
        source = source.replaceAll(
          RegExp(
            r'^[ \t]*' + RegExp.escape(importLine) + r'[ \t]*\n?',
            multiLine: true,
          ),
          '',
        );
      }
    }

    if (code != null && code.trim().isNotEmpty) {
      source = _removeInjectedCode(source, code);
    }

    source = source.replaceAll(RegExp(r'\n{3,}'), '\n\n').trimRight();
    await file.writeAsString('$source\n');
  }

  String _removeInjectedCode(String source, String rawCode) {
    final code = rawCode.trimRight();
    if (code.isEmpty) return source;

    final rawLines = code.split('\n');
    if (rawLines.length == 1) {
      final escaped = RegExp.escape(rawLines.first.trim());
      return source.replaceAll(
        RegExp(r'^[ \t]*' + escaped + r',?[ \t]*\n?', multiLine: true),
        '',
      );
    }

    final lines = rawLines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return source;

    final pattern = lines
        .map((line) => r'[ \t]*' + RegExp.escape(line))
        .join(r'\n');

    return source.replaceAll(RegExp('$pattern\n?', multiLine: true), '');
  }
}
