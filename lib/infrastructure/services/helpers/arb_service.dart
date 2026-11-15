import 'dart:convert';

import 'package:path/path.dart' as p;

import 'directory_service.dart';
import 'file_service.dart';

class ArbService {
  final DirectoryService _directoryService;
  final FileService _fileService;

  const ArbService({
    required DirectoryService directoryService,
    required FileService fileService,
  }) : _directoryService = directoryService,
       _fileService = fileService;

  Future<void> injectBySnippet({
    required String arbPath,
    required String arbSnippet,
  }) async {
    final content = await _fileService.readAsString(arbPath);

    // Cari posisi kurung kurawal penutup terakhir '}'
    final lastBraceIndex = content.lastIndexOf('}');
    if (lastBraceIndex != -1) {
      final subContent = content.substring(0, lastBraceIndex).trim();
      final needsComma = !subContent.endsWith(',');

      // Gabungkan isi lama dengan snippet baru secara aman
      final updatedContent =
          '$subContent${needsComma ? ',' : ''}\n$arbSnippet}';

      await _fileService.writeAsString(path: arbPath, content: updatedContent);
    }
  }

  Future<void> unjectBetweenKeys({
    required String arbPath,
    required String startKey,
    required String endKey,
  }) async {
    final content = await _fileService.readAsString(arbPath);
    final jsonMap = Map<String, dynamic>.from(jsonDecode(content) as Map);

    final keys = jsonMap.keys.toList();

    final startIndex = keys.indexOf(startKey);
    final endIndex = keys.indexOf(endKey);

    // Pastikan kedua batas ditemukan dan posisinya valid
    if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
      // Hapus semua key dari startKey hingga endKey (termasuk key kustom di antaranya)
      for (int i = endIndex; i >= startIndex; i--) {
        jsonMap.remove(keys[i]);
      }

      const encoder = JsonEncoder.withIndent('  ');
      final updatedContent = encoder.convert(jsonMap);
      await _fileService.writeAsString(path: arbPath, content: updatedContent);
    }
  }

  Future<void> injectEntriesBeforeKey({
    required String arbPath,
    required String endKey,
    required Map<String, dynamic> arbEntries,
  }) async {
    final content = await _fileService.readAsString(arbPath);
    final jsonMap = Map<String, dynamic>.from(jsonDecode(content) as Map);

    // Sisipkan entri baru tepat sebelum endDividerKey
    if (jsonMap.containsKey(endKey)) {
      final newMap = <String, dynamic>{};
      for (final entry in jsonMap.entries) {
        if (entry.key == endKey) {
          newMap.addAll(arbEntries);
        }
        newMap[entry.key] = entry.value;
      }

      const encoder = JsonEncoder.withIndent('  ');
      final updatedContent = encoder.convert(newMap);
      await _fileService.writeAsString(path: arbPath, content: updatedContent);
    } else {
      // Fallback jika endDivider tidak ditemukan
      jsonMap.addAll(arbEntries);

      const encoder = JsonEncoder.withIndent('  ');
      final updatedContent = encoder.convert(jsonMap);
      await _fileService.writeAsString(path: arbPath, content: updatedContent);
    }
  }

  Future<void> unjectEntries({
    required String arbPath,
    required Map<String, dynamic> arbEntries,
  }) async {
    final content = await _fileService.readAsString(arbPath);
    final jsonMap = Map<String, dynamic>.from(jsonDecode(content) as Map);

    bool modified = false;
    for (final key in arbEntries.keys) {
      if (jsonMap.containsKey(key)) {
        jsonMap.remove(key);
        modified = true;
      }
    }

    if (modified) {
      const encoder = JsonEncoder.withIndent('  ');
      final updatedContent = encoder.convert(jsonMap);
      await _fileService.writeAsString(path: arbPath, content: updatedContent);
    }
  }

  Future<List<String>> getArbPaths(String modulePath) async {
    return await _directoryService.listPaths(
      dirPath: p.join(modulePath, 'lib', 'l10n'),
      where: (fileSystem, isFile) => isFile && fileSystem.path.endsWith('.arb'),
    );
  }
}
