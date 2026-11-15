import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:fsda_cli/infrastructure/visitors/failure_x_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('FailureXVisitor', () {
    test(
      'Given code containing localizeAny method with a return statement, '
      'When visiting the AST, '
      'Then it should trigger onFound callback with the offset of the return statement',
      () {
        // Given
        const code = '''
          class FailureX {
            String localizeAny() {
              return l10n.unknownError;
            }
          }
        ''';

        final parseResult = parseString(content: code);
        int? foundOffset;

        final visitor = FailureXVisitor((offset) {
          foundOffset = offset;
        });

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(foundOffset, isNotNull);
        // Memastikan offset yang ditemukan mengarah ke statement return
        final substring = code.substring(foundOffset!);
        expect(substring.trim().startsWith('return'), isTrue);
      },
    );

    test(
      'Given code containing localizeAny method without return statement inside block body, '
      'When visiting the AST, '
      'Then it should trigger onFound callback with the right bracket offset of the block',
      () {
        // Given
        const code = '''
          class FailureX {
            void localizeAny() {
              // do nothing
            }
          }
        ''';

        final parseResult = parseString(content: code);
        int? foundOffset;

        final visitor = FailureXVisitor((offset) {
          foundOffset = offset;
        });

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(foundOffset, isNotNull);
        // Memastikan karakter pada offset tersebut adalah penutup blok '}'
        expect(code[foundOffset!], equals('}'));
      },
    );

    test('Given code without localizeAny method, '
        'When visiting the AST, '
        'Then it should not trigger onFound callback', () {
      // Given
      const code = '''
          class FailureX {
            void otherMethod() {
              return;
            }
          }
        ''';

      final parseResult = parseString(content: code);
      bool isFoundCalled = false;

      final visitor = FailureXVisitor((offset) {
        isFoundCalled = true;
      });

      // When
      parseResult.unit.visitChildren(visitor);

      // Then
      expect(isFoundCalled, isFalse);
    });
  });
}
