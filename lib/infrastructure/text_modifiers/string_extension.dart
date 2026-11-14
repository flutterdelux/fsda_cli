extension StringCasingExtension on String {
  // this => has to be snake_case

  String get pascalCase => split('_').map(_capitalize).join('');

  String get camelCase {
    return split('_')
        .asMap()
        .entries
        .map((e) => e.key == 0 ? e.value.toLowerCase() : _capitalize(e.value))
        .join('');
  }

  String get capitalCase {
    return split('_')
        .asMap()
        .entries
        .map((e) => e.key == 0 ? _capitalize(e.value) : e.value.toLowerCase())
        .join(' ');
  }

  String get titleCase => split('_').map(_capitalize).join(' ');

  String get kebabCase => split('_').join('-');

  String get sentenceCase => split('_').join(' ').toLowerCase();

  // Helper fungsi internal untuk mengubah satu kata menjadi format PascalCase
  String _capitalize(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  // this => has to be PascalCase
  String get snakeCase => replaceAllMapped(
    RegExp(r'(?<=[a-z])[A-Z]'),
    (Match m) => '_${m.group(0)}',
  ).toLowerCase();
}
