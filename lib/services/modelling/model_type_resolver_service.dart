import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';

class ModelTypeResolution {
  const ModelTypeResolution({
    required this.artifactPaths,
    required this.enumConverterTypes,
  });

  final Map<String, String> artifactPaths;
  final Set<String> enumConverterTypes;

  String? importFor(String type, {required String fromDirectory}) {
    final artifactPath = artifactPaths[type];
    if (artifactPath == null) return null;
    final relative = p.relative(artifactPath, from: fromDirectory);
    return "import '${p.posix.normalize(relative.replaceAll('\\', '/'))}';";
  }

  List<String> importsFor({
    required String fromDirectory,
    Iterable<String> excluding = const <String>[],
  }) {
    final excluded = excluding.toSet();
    final imports = <String>{};
    for (final type in artifactPaths.keys) {
      if (excluded.contains(type)) continue;
      final directive = importFor(type, fromDirectory: fromDirectory);
      if (directive != null) imports.add(directive);
    }
    return imports.toList()..sort();
  }
}

class ModelTypeResolverService {
  const ModelTypeResolverService();

  static const _directories = <String>[
    'domain/entities',
    'domain/params',
    'data/dtos',
    'domain/enums',
    'data/requests',
  ];

  static const _ignoredTokens = <String>{
    'String',
    'int',
    'double',
    'num',
    'bool',
    'dynamic',
    'Object',
    'DateTime',
    'Duration',
    'BigInt',
    'List',
    'Map',
    'Set',
    'Iterable',
    'Future',
    'Stream',
    'void',
    'Null',
    'Never',
    'NetworkFile',
  };

  Future<ModelTypeResolution> resolve({
    required String featureRoot,
    required List<TypedProp> props,
  }) async {
    final types = <String>{};
    for (final prop in props) {
      final type = prop.typeWithoutNullability.replaceAll(' ', '');
      for (final match in RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type)) {
        final token = match.group(0);
        if (token != null && !_ignoredTokens.contains(token)) types.add(token);
      }
    }

    final paths = <String, String>{};
    final enumConverterTypes = <String>{};
    for (final type in types) {
      final fileName = '${type.snakeCase}.dart';
      for (final directory in _directories) {
        final candidate = p.join(featureRoot, directory, fileName);
        if (!await File(candidate).exists()) continue;

        paths[type] = candidate;
        if (directory == 'domain/enums') {
          final converter = p.join(
            featureRoot,
            'data',
            'converters',
            '${type.snakeCase}_converter.dart',
          );
          if (await File(converter).exists()) {
            enumConverterTypes.add(type);
          }
        }
        break;
      }
    }

    return ModelTypeResolution(
      artifactPaths: paths,
      enumConverterTypes: enumConverterTypes,
    );
  }
}
