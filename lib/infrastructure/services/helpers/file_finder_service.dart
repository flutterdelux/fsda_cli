import 'package:path/path.dart' as p;

import '../../text_modifiers/string_extension.dart';
import 'directory_service.dart';
import 'file_service.dart';

const _featureSubDirs = [
  'data/converters',
  'data/dtos',
  'data/requests',
  'data/responses',
  'domain/entities',
  'domain/enums',
  'domain/usecases',
  'domain/params',
];

class FileFinderService {
  final FileService _fileService;
  final DirectoryService _directoryService;

  const FileFinderService({
    required FileService fileService,
    required DirectoryService directoryService,
  }) : _fileService = fileService,
       _directoryService = directoryService;

  Future<String?> findFile({
    required String rawRef,
    required String modulePath,
  }) async {
    final fileName = '${rawRef.snakeCase}.dart';

    if (rawRef.endsWith('Localizations')) {
      final generatedPath = p.join(
        modulePath,
        'lib',
        'src',
        'generated',
        fileName,
      );
      if (await _fileService.exists(generatedPath)) {
        return generatedPath;
      }
    }

    if (rawRef.endsWith('Exception')) {
      final exceptionPath = p.join(
        modulePath,
        'lib',
        'src',
        'shared',
        'data',
        'errors',
        fileName,
      );
      if (await _fileService.exists(exceptionPath)) {
        return exceptionPath;
      }
    }

    final featurePaths = await _directoryService.listPaths(
      dirPath: p.join(modulePath, 'lib', 'src', 'features'),
      where: (fileSystem, isFile) => !isFile,
    );
    for (final featurePath in featurePaths) {
      for (final subDir in _featureSubDirs) {
        final targetPath = p.join(featurePath, subDir, fileName);
        if (await _fileService.exists(targetPath)) {
          return targetPath;
        }
      }
    }

    return null;
  }
}
