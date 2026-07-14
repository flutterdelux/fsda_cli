import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../../generated/package_bundle.dart';
import '../../models/infra_template_spec.dart';

class InfraSpecBundleReader {
  const InfraSpecBundleReader();

  List<InfraTemplateSpec> readInfraSpecs({
    required Set<String> infraTemplatePackages,
  }) {
    final specs = <InfraTemplateSpec>[];

    final packageNames = infraTemplatePackages.toList()..sort();
    for (final packageName in packageNames) {
      final yaml = _readInfraSpecYaml(packageName: packageName);
      if (yaml == null) continue;

      specs.add(_parseInfraTemplateSpec(packageName: packageName, yaml: yaml));
    }

    return specs;
  }

  YamlMap? _readInfraSpecYaml({required String packageName}) {
    final encoded = packageBundle[packageName]?['spec.yaml'];
    if (encoded == null) {
      return null;
    }

    final raw = utf8.decode(base64Decode(encoded));
    final parsed = loadYaml(raw);
    if (parsed is! YamlMap) {
      return null;
    }

    return parsed;
  }

  InfraTemplateSpec _parseInfraTemplateSpec({
    required String packageName,
    required YamlMap yaml,
  }) {
    final coreDi = yaml['core_di'] is YamlMap
        ? yaml['core_di'] as YamlMap
        : null;
    final externalDi = yaml['external_di'] is YamlMap
        ? yaml['external_di'] as YamlMap
        : null;
    final external = yaml['external'] is YamlMap
        ? yaml['external'] as YamlMap
        : null;
    final parsedAppDependencies = _parseStringList(yaml['app_dependencies']);

    return InfraTemplateSpec(
      packageName: packageName,
      coreDiImports: _parseImportLines(coreDi?['import']),
      coreDiCode: _parseCode(coreDi?['code']),
      externalDiImports: _parseImportLines(externalDi?['import']),
      externalDiCode: _parseCode(externalDi?['code']),
      externalCodeImports: _parseImportLines(external?['import']),
      externalCode: _parseCode(external?['code']),
      appDependencies: parsedAppDependencies.isNotEmpty
          ? parsedAppDependencies
          : _parseStringList(yaml['dependencies']),
    );
  }

  Set<String> _parseImportLines(Object? rawImport) {
    if (rawImport == null) return <String>{};

    final result = <String>{};
    final lines = rawImport.toString().split('\n');

    for (final rawLine in lines) {
      var line = rawLine.trim();
      if (line.isEmpty) continue;

      line = _normalizeImportLine(line);
      if (line.isEmpty) continue;

      result.add(line);
    }

    return result;
  }

  String _normalizeImportLine(String line) {
    var normalized = line.trim();
    if (normalized.length >= 2) {
      final startsWithQuote =
          normalized.startsWith('"') || normalized.startsWith("'");
      final endsWithQuote =
          normalized.endsWith('"') || normalized.endsWith("'");

      if (startsWithQuote && endsWithQuote) {
        normalized = normalized.substring(1, normalized.length - 1).trim();
      }
    }

    return normalized;
  }

  String? _parseCode(Object? rawCode) {
    if (rawCode == null) return null;
    final code = rawCode.toString().trimRight();
    if (code.trim().isEmpty) return null;
    return code;
  }

  Set<String> _parseStringList(Object? rawList) {
    if (rawList is! YamlList) return <String>{};

    return rawList
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }
}
