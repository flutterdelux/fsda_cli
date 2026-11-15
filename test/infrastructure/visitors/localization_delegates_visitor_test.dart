import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:fsda_cli/infrastructure/visitors/localization_delegates_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('LocalizationsDelegatesVisitor', () {
    test(
      'Given code containing localizationsDelegates with non-empty list literal, '
      'When visiting the AST, '
      'Then it should trigger onFound callback with the end offset of the last element',
      () {
        // Given
        const code = '''
          void main() {
            const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
              ],
            );
          }
        ''';

        final parseResult = parseString(content: code);
        int? foundOffset;

        final visitor = LocalizationsDelegatesVisitor((offset) {
          foundOffset = offset;
        });

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(foundOffset, isNotNull);
        final substringUpToOffset = code.substring(0, foundOffset!);
        expect(
          substringUpToOffset,
          contains('GlobalMaterialLocalizations.delegate'),
        );
      },
    );

    test(
      'Given code containing localizationsDelegates with empty list literal, '
      'When visiting the AST, '
      'Then it should trigger onFound callback with the left bracket end offset',
      () {
        // Given
        const code = '''
          void main() {
            const MaterialApp(
              localizationsDelegates: [],
            );
          }
        ''';

        final parseResult = parseString(content: code);
        int? foundOffset;

        final visitor = LocalizationsDelegatesVisitor((offset) {
          foundOffset = offset;
        });

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(foundOffset, isNotNull);
        final leftBracketIndex = code.indexOf('[');
        expect(foundOffset, equals(leftBracketIndex + 1));
      },
    );

    test('Given code without localizationsDelegates named expression, '
        'When visiting the AST, '
        'Then it should not trigger onFound callback', () {
      // Given
      const code = '''
          void main() {
            const MaterialApp(
              title: 'Flutter App',
            );
          }
        ''';

      final parseResult = parseString(content: code);
      bool isFoundCalled = false;

      final visitor = LocalizationsDelegatesVisitor((offset) {
        isFoundCalled = true;
      });

      // When
      parseResult.unit.visitChildren(visitor);

      // Then
      expect(isFoundCalled, isFalse);
    });
  });
}
