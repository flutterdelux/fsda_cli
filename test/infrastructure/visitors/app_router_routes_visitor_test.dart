import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:fsda_cli/infrastructure/visitors/app_router_routes_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('AppRouterRoutesVisitor', () {
    test(
      'Given code containing routes named expression with a list literal, '
      'When visiting the AST, '
      'Then it should trigger onFound callback with the right bracket offset',
      () {
        // Given
        const code = '''
          final router = GoRouter(
            routes: [
              GoRoute(path: '/'),
            ],
          );
        ''';

        final parseResult = parseString(content: code);
        int? foundOffset;

        final visitor = AppRouterRoutesVisitor((offset) {
          foundOffset = offset;
        });

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(foundOffset, isNotNull);
        // Memastikan karakter pada offset tersebut adalah penutup list ']'
        expect(code[foundOffset!], equals(']'));
      },
    );

    test('Given code without routes named expression, '
        'When visiting the AST, '
        'Then it should not trigger onFound callback', () {
      // Given
      const code = '''
          final router = GoRouter(
            initialLocation: '/',
          );
        ''';

      final parseResult = parseString(content: code);
      bool isFoundCalled = false;

      final visitor = AppRouterRoutesVisitor((offset) {
        isFoundCalled = true;
      });

      // When
      parseResult.unit.visitChildren(visitor);

      // Then
      expect(isFoundCalled, isFalse);
    });
  });
}
