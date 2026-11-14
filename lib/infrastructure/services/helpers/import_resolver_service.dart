import 'dart:io';

import 'package:path/path.dart' as p;

import 'file_service.dart';

const _dartCoreTypes = {
  'String',
  'int',
  'double',
  'bool',
  'num',
  'DateTime',
  'Duration',
  'Uri',
  'List',
  'Map',
  'Set',
  'Symbol',
  'Function',
  'dynamic',
  'void',
  'Object',
  'Failure',
};

const _dartSpecialImports = {
  'Uint8List': "import 'dart:typed_data';",
  'Int8List': "import 'dart:typed_data';",
  'Uint32List': "import 'dart:typed_data';",
  'Int32List': "import 'dart:typed_data';",
  'File': "import 'dart:io';",
  'Directory': "import 'dart:io';",
};

const _appCoreTypes = {
  'NetworkFile',
  'UtcDateTimeConverter',
  'AsyncResult',
  'Result',
  'StreamResult',
};
const _appL10nTypes = {'AppLocalizations'};

final featureSubDirs = [
  p.join('domain', 'usecases'),
  p.join('domain', 'entities'),
  p.join('domain', 'params'),
  p.join('domain', 'enums'),
  p.join('data', 'dtos'),
  p.join('data', 'requests'),
  p.join('data', 'responses'),
  p.join('data', 'converters'),
];

class ImportResolverService {
  final FileService _fileService;

  const ImportResolverService({required FileService fileService})
    : _fileService = fileService;

  Future<Set<String>> resolve({
    required Set<String> rawTypes,
    required String targetFilePath,
    required String featurePath,
  }) async {
    // 1. Baca isi file target terlebih dahulu untuk validasi apakah tipe digunakan atau tidak
    if (!await _fileService.exists(targetFilePath)) {
      return {};
    }
    final targetContent = await _fileService.readAsString(targetFilePath);

    final cleanedTypes = rawTypes
        .map(
          (t) => t
              .replaceAll('?', '')
              .replaceAll('List<', '')
              .replaceAll('>', '')
              .trim(),
        )
        .toSet();

    final imports = <String>{};

    for (final rawRef in cleanedTypes) {
      if (rawRef.isEmpty || _dartCoreTypes.contains(rawRef)) continue;

      // 2. Cek apakah teks file target benar-benar memuat tipe/referensi ini.
      // Jika tidak ada sama sekali di dalam file, langsung continue (lewati proses pencarian).
      if (!targetContent.contains(rawRef)) {
        continue;
      }

      if (_dartSpecialImports.containsKey(rawRef)) {
        imports.add(_dartSpecialImports[rawRef]!);
        continue;
      }

      if (_appCoreTypes.contains(rawRef)) {
        imports.add("import 'package:app_core/app_core.dart';");
        continue;
      }

      if (_appL10nTypes.contains(rawRef)) {
        imports.add("import 'package:app_l10n/app_l10n.dart';");
        continue;
      }

      final nameSnake = rawRef
          .replaceAllMapped(
            RegExp(r'(?<=[a-z])[A-Z]'),
            (Match m) => '_${m.group(0)}',
          )
          .toLowerCase();

      if (rawRef.endsWith('Localizations')) {
        if (await _tryResolveInModuleGeneratedDir(
          featurePath: featurePath,
          nameSnake: nameSnake,
          targetFilePath: targetFilePath,
          imports: imports,
        )) {
          continue;
        }
      }

      if (rawRef.endsWith('Exception')) {
        if (await _tryResolveInModuleExceptionDir(
          featurePath: featurePath,
          nameSnake: nameSnake,
          targetFilePath: targetFilePath,
          imports: imports,
        )) {
          continue;
        }
      }

      bool foundInSameFeature = false;

      // 3. Cari di feature saat ini terlebih dahulu
      for (final subDir in featureSubDirs) {
        if (await _tryResolveInDir(
          featurePath: featurePath,
          subDir: subDir,
          nameSnake: nameSnake,
          targetFilePath: targetFilePath,
          imports: imports,
        )) {
          foundInSameFeature = true;
          break;
        }
      }

      // 4. Jika tidak ketemu, cari lintas fitur di bawah module root yang sama
      if (!foundInSameFeature) {
        await _resolveAcrossModuleFeatures(
          featurePath: featurePath,
          possibleSubDirs: featureSubDirs,
          nameSnake: nameSnake,
          targetFilePath: targetFilePath,
          imports: imports,
        );
      }
    }

    return imports;
  }

  Future<bool> _tryResolveInDir({
    required String featurePath,
    required String subDir,
    required String nameSnake,
    required String targetFilePath,
    required Set<String> imports,
  }) async {
    final possibleFileNames = [
      '$nameSnake.dart',
      // '${nameSnake}_entity.dart',
      // '${nameSnake}_param.dart',
      // '${nameSnake}_dto.dart',
      // '${nameSnake}_request.dart',
      // '${nameSnake}_response.dart',
      // '${nameSnake}_converter.dart',
      // '${nameSnake}_use_case.dart',
    ];

    for (final fileName in possibleFileNames) {
      final targetPath = p.join(featurePath, subDir, fileName);
      if (await _fileService.exists(targetPath)) {
        final relativePath = p.relative(
          targetPath,
          from: p.dirname(targetFilePath),
        );
        imports.add("import '${relativePath.replaceAll(r'\', '/')}';");
        return true;
      }
    }
    return false;
  }

  Future<bool> _resolveAcrossModuleFeatures({
    required String featurePath,
    required List<String> possibleSubDirs,
    required String nameSnake,
    required String targetFilePath,
    required Set<String> imports,
  }) async {
    final featuresDir = Directory(p.dirname(featurePath));
    if (!await featuresDir.exists()) return false;

    try {
      await for (final entity in featuresDir.list()) {
        if (entity is Directory) {
          final otherFeaturePath = entity.path;
          if (otherFeaturePath == featurePath) continue;

          for (final subDir in possibleSubDirs) {
            if (await _tryResolveInDir(
              featurePath: otherFeaturePath,
              subDir: subDir,
              nameSnake: nameSnake,
              targetFilePath: targetFilePath,
              imports: imports,
            )) {
              return true;
            }
          }
        }
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _tryResolveInModuleGeneratedDir({
    required String featurePath,
    required String nameSnake,
    required String targetFilePath,
    required Set<String> imports,
  }) async {
    final generatedDir = p.join(p.dirname(p.dirname(featurePath)), 'generated');

    final targetPath = p.join(generatedDir, '$nameSnake.dart');
    if (await _fileService.exists(targetPath)) {
      final relativePath = p.relative(
        targetPath,
        from: p.dirname(targetFilePath),
      );
      imports.add("import '${relativePath.replaceAll(r'\', '/')}';");
      return true;
    }

    return false;
  }

  Future<bool> _tryResolveInModuleExceptionDir({
    required String featurePath,
    required String nameSnake,
    required String targetFilePath,
    required Set<String> imports,
  }) async {
    final shareDir = p.join(p.dirname(p.dirname(featurePath)), 'shared');

    final targetPath = p.join(shareDir, 'data', 'errors', '$nameSnake.dart');
    if (await _fileService.exists(targetPath)) {
      final relativePath = p.relative(
        targetPath,
        from: p.dirname(targetFilePath),
      );
      imports.add("import '${relativePath.replaceAll(r'\', '/')}';");
      return true;
    }

    return false;
  }
}
