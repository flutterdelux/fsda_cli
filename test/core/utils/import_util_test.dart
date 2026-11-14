import 'package:fsda_cli/core/utils/import_util.dart';
import 'package:test/test.dart';

void main() {
  group('ImportUtil Tests', () {
    test('should sort imports by priority (dart -> package -> relative)', () {
      final rawImports = [
        "import '../core/utils.dart';",
        "import 'package:flutter/material.dart';",
        "import 'dart:async';",
      ];

      final sorted = ImportUtil.sort(rawImports);

      expect(sorted.toList(), [
        "import 'dart:async';",
        "import 'package:flutter/material.dart';",
        "import '../core/utils.dart';",
      ]);
    });

    test('should sort alphabetically when priority is the same', () {
      final rawImports = [
        "import 'package:z_package/z.dart';",
        "import 'package:a_package/a.dart';",
        "import 'dart:z';",
        "import 'dart:a';",
        "import '../b.dart';",
        "import '../a.dart';",
      ];

      final sorted = ImportUtil.sort(rawImports);

      expect(sorted.toList(), [
        "import 'dart:a';",
        "import 'dart:z';",
        "import 'package:a_package/a.dart';",
        "import 'package:z_package/z.dart';",
        "import '../a.dart';",
        "import '../b.dart';",
      ]);
    });

    test('should remove duplicate imports using Set', () {
      final rawImports = [
        "import 'dart:async';",
        "import 'dart:async';",
        "import 'package:flutter/material.dart';",
      ];

      final sorted = ImportUtil.sort(rawImports);

      expect(sorted.length, 2);
      expect(sorted.toList(), [
        "import 'dart:async';",
        "import 'package:flutter/material.dart';",
      ]);
    });

    test('should handle empty iterable correctly', () {
      final sorted = ImportUtil.sort([]);
      expect(sorted, isEmpty);
    });
  });
}
