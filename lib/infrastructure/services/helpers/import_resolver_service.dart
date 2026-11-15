import 'package:path/path.dart' as p;

import 'file_finder_service.dart';
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

class ImportResolverService {
  final FileService _fileService;
  final FileFinderService _fileFinderService;

  const ImportResolverService({
    required FileService fileService,
    required FileFinderService fileFinderService,
  }) : _fileService = fileService,
       _fileFinderService = fileFinderService;

  Future<Set<String>> resolve({
    required Set<String> rawTypes,
    required String targetFilePath,
    required String modulePath,
  }) async {
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

      final foundFilePath = await _fileFinderService.findFile(
        rawRef: rawRef,
        modulePath: modulePath,
      );

      if (foundFilePath != null) {
        final relativePath = p.relative(
          foundFilePath,
          from: p.dirname(targetFilePath),
        );
        imports.add("import '${relativePath.replaceAll(r'\', '/')}';");
      }
    }

    return imports;
  }
}
