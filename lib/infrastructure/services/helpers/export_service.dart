import 'file_service.dart';

class ExportService {
  final FileService _fileService;

  const ExportService({required FileService fileService})
    : _fileService = fileService;

  Future<void> inject({
    required String barrelPath,
    required List<String> exportLines,
    required String checkpoint,
  }) async {
    if (exportLines.isEmpty) return;
    if (!await _fileService.exists(barrelPath)) return;

    String content = await _fileService.readAsString(barrelPath);

    // Filter hanya baris yang belum ada di dalam file (menghindari duplikasi)
    final linesToInject = exportLines
        .where((line) => !content.contains(line))
        .toList();

    if (linesToInject.isEmpty) return;

    final formattedInject = linesToInject.join('\n');

    if (content.contains(checkpoint)) {
      content = content.replaceFirst(
        checkpoint,
        '$checkpoint\n$formattedInject',
      );
    } else {
      content = '$formattedInject\n$content';
    }

    await _fileService.writeAsString(path: barrelPath, content: content);
  }

  Future<void> unject({
    required String barrelPath,
    required List<String> exportLines,
  }) async {
    if (exportLines.isEmpty) return;
    if (!await _fileService.exists(barrelPath)) return;

    final content = await _fileService.readAsString(barrelPath);

    // Ubah ke Set untuk pencarian O(1) yang cepat saat filtering
    final targetLinesSet = exportLines.map((e) => e.trim()).toSet();

    final lines = content.split('\n');
    final initialLength = lines.length;

    lines.removeWhere((line) => targetLinesSet.contains(line.trim()));

    // Jika tidak ada baris yang terhapus, tidak perlu menimpa/menulis file kembali
    if (lines.length == initialLength) return;

    await _fileService.writeAsString(
      path: barrelPath,
      content: lines.join('\n'),
    );
  }
}
