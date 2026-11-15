import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:fsda_cli/infrastructure/visitors/last_getter_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('LastGetterVisitor', () {
    test('Given code containing multiple getters in a class, '
        'When visiting the AST, '
        'Then it should find and store the end offset of the last getter', () {
      // Given
      const code = '''
          class UserProfile {
            String get firstName => 'John';
            
            String get lastName => 'Doe';
            
            void normalMethod() {}
          }
        ''';

      final parseResult = parseString(content: code);
      final visitor = LastGetterVisitor();

      // When
      parseResult.unit.visitChildren(visitor);

      // Then
      expect(visitor.insertOffset, isNotNull);
      // Memastikan offset menunjuk pada akhir getter terakhir (lastName)
      final substringUpToOffset = code.substring(0, visitor.insertOffset!);
      expect(substringUpToOffset, contains('String get lastName => \'Doe\';'));
      expect(substringUpToOffset, isNot(contains('void normalMethod() {}')));
    });

    test('Given code without any getter, '
        'When visiting the AST, '
        'Then insertOffset should remain null', () {
      // Given
      const code = '''
          class UserProfile {
            void normalMethod() {}
          }
        ''';

      final parseResult = parseString(content: code);
      final visitor = LastGetterVisitor();

      // When
      parseResult.unit.visitChildren(visitor);

      // Then
      expect(visitor.insertOffset, isNull);
    });
  });
}
