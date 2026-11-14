abstract final class ImportUtil {
  /// Helper untuk mengurutkan import menjadi 3 level:
  /// 1. dart: (pustaka bawaan dart)
  /// 2. package: (pustaka eksternal/internal package)
  /// 3. relative path (../ atau ./ )
  static Set<String> sort(Iterable<String> rawImports) {
    final uniqueImports = rawImports.toList();

    uniqueImports.sort((a, b) {
      int getPriority(String imp) {
        if (imp.contains('import \'dart:')) return 1;
        if (imp.contains('import \'package:')) return 2;
        return 3; // Relative path (../ atau ./ atau lainnya)
      }

      final priorityA = getPriority(a);
      final priorityB = getPriority(b);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // Jika prioritas sama, urutkan secara alfabetis (A-Z)
      return a.compareTo(b);
    });

    return uniqueImports.toSet();
  }
}
