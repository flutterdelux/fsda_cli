import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../models/bundle_template.dart';
import '../models/template_spec.dart';
import 'file_service.dart';

class BundleService {
  final FileService fileService;

  const BundleService({required this.fileService});

  /// Mengambil template dari bundle Base64, me-load spec.yaml, dan menembak ke FileService
  Future<BundleTemplate> unpackAndBake({
    required Map<String, Map<String, String>> bundleMap, // e.g. packageBundle
    required String templateName, // e.g. "app_core"
    required String targetPath, // e.g. ".../packages/app_core"
  }) async {
    final base64Files = bundleMap[templateName];

    if (base64Files == null) {
      throw Exception(
        '$templateName template not found in the bundle. Available templates: \n${bundleMap.keys.map((key) => '  - $key').join('\n')}',
      );
    }

    final decodedFiles = <String, List<int>>{};
    YamlMap? specMap;

    for (final entry in base64Files.entries) {
      final relativePath = entry.key;
      final bytes = base64Decode(entry.value);

      decodedFiles[relativePath] = bytes;

      if (relativePath == 'spec.yaml') {
        final yamlString = utf8.decode(bytes);
        specMap = loadYaml(yamlString) as YamlMap;
      }
    }

    if (specMap == null) {
      throw Exception(
        'Template "$templateName" broken: spec.yaml not found in the bundle.',
      );
    }

    await fileService.generateTemplate(path: targetPath, files: decodedFiles);

    return BundleTemplate(
      files: decodedFiles,
      spec: TemplateSpec.fromYaml(specMap),
    );
  }
}
