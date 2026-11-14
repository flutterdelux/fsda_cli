import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import '../../../core/utils/import_util.dart';
import 'file_service.dart';

class ImportService {
  final FileService _fileService;

  const ImportService({required FileService fileService})
    : _fileService = fileService;

  Future<void> injectImport({
    required String path,
    required Set<String> imports,
  }) async {
    if (imports.isEmpty) return;

    if (!await _fileService.exists(path)) {
      throw Exception('The file to be injected with "imports" was not found.');
    }

    final content = await _fileService.readAsString(path);

    // Tambahkan throwIfDiagnostics: false agar tidak throw exception saat ada syntax warning/error
    final parseResult = parseString(
      content: content,
      throwIfDiagnostics: false,
    );
    final unit = parseResult.unit;

    // 1. Ambil semua import yang sudah ada di dalam file berdasarkan AST directives
    final existingImports = <String>{};
    int firstImportOffset = -1;
    int lastImportEnd = -1;

    for (final directive in unit.directives) {
      if (directive is ImportDirective) {
        existingImports.add(directive.toSource());
        if (firstImportOffset == -1) {
          firstImportOffset = directive.offset;
        }
        lastImportEnd = directive.end;
      }
    }

    // 2. Gabungkan import lama dengan import baru dari parameter
    final combinedImports = {...existingImports, ...imports};

    // 3. Susun dan urutkan menggunakan ImportUtil.sort
    final sortedImports = ImportUtil.sort(combinedImports);
    final sortedImportsString = sortedImports.join('\n');

    // 4. Masukkan kembali ke file dengan aman
    String updatedContent;
    if (existingImports.isEmpty) {
      // Jika file belum memiliki directive import sama sekali, letakkan di paling atas file
      updatedContent = '$sortedImportsString\n\n$content';
    } else {
      // Ganti blok import yang lama dengan blok import baru yang sudah digabung & diurutkan
      updatedContent = content.replaceRange(
        firstImportOffset,
        lastImportEnd,
        sortedImportsString,
      );
    }

    await _fileService.writeAsString(path: path, content: updatedContent);
  }
}
