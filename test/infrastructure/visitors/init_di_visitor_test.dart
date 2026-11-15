import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:fsda_cli/infrastructure/visitors/init_di_visitor.dart'; // Sesuaikan import path dengan project Anda
import 'package:test/test.dart';

void main() {
  group('InitDiVisitor', () {
    test(
      'Given code containing initDI function declaration with a block body, '
      'When visiting the AST, '
      'Then it should trigger onFound callback with the right bracket offset of the block',
      () {
        // Given
        const code = '''
          void initDI() {
            // register dependencies
          }
        ''';

        final parseResult = parseString(content: code);
        int? foundOffset;

        final visitor = InitDiVisitor((offset) {
          foundOffset = offset;
        });

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(foundOffset, isNotNull);
        // Memastikan karakter pada offset tersebut adalah penutup kurung kurawal '}'
        expect(code[foundOffset!], equals('}'));
      },
    );

    test('Given code without initDI function declaration, '
        'When visiting the AST, '
        'Then it should not trigger onFound callback', () {
      // Given
      const code = '''
          void main() {
            runApp(MyApp());
          }
        ''';

      final parseResult = parseString(content: code);
      bool isFoundCalled = false;

      final visitor = InitDiVisitor((offset) {
        isFoundCalled = true;
      });

      // When
      parseResult.unit.visitChildren(visitor);

      // Then
      expect(isFoundCalled, isFalse);
    });
  });
}
