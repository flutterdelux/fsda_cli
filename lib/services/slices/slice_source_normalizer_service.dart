import 'dart:convert';

class SliceSourceNormalizerService {
  const SliceSourceNormalizerService();

  void normalizeStandaloneDartFiles(Map<String, List<int>> files) {
    for (final entry in files.entries.toList(growable: false)) {
      if (!entry.key.endsWith('.dart')) {
        continue;
      }

      final source = utf8.decode(entry.value);
      final normalized = _normalizeGeneratedDartSource(source);
      files[entry.key] = utf8.encode(normalized);
    }
  }

  String _normalizeGeneratedDartSource(String source) {
    var normalized = source
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n');

    normalized = normalized.replaceAllMapped(
      RegExp(r',\n\s*\n(\s*(?:@|required\b|[A-Za-z_]))'),
      (match) => ',\n${match.group(1)!}',
    );

    normalized = normalized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return normalized.trimRight();
  }
}
