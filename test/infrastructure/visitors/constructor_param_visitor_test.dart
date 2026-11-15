import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:fsda_cli/infrastructure/visitors/constructor_param_visitor.dart'; // Sesuaikan import path dengan project Anda
import 'package:test/test.dart';

void main() {
  group('ConstructorParamVisitor', () {
    test(
      'Given class code with default constructor containing field formal parameters and implicit field types, '
      'When visiting the AST, '
      'Then it should extract class name and parameters metadata correctly',
      () {
        // Given
        const code = '''
          class UserRepoImpl implements UserRepo {
            final ApiClient _client;
            final int timeout = 30;

            UserRepoImpl(this._client, {this.timeout = 60, Key? key});
          }
        ''';

        final parseResult = parseString(content: code);
        final visitor = ConstructorParamVisitor();

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(visitor.className, equals('UserRepoImpl'));
        expect(visitor.parameters.length, equals(2));

        // Parameter 1: this._client (type diambil dari deklarasi field class)
        expect(visitor.parameters[0].name, equals('_client'));
        expect(visitor.parameters[0].type, equals('ApiClient'));
        expect(visitor.parameters[0].isNamed, isFalse);
        expect(visitor.parameters[0].defaultValue, isNull);

        // Parameter 2: this.timeout (default value = 60)
        expect(visitor.parameters[1].name, equals('timeout'));
        expect(visitor.parameters[1].type, equals('int'));
        expect(visitor.parameters[1].isNamed, isTrue);
        expect(visitor.parameters[1].defaultValue, equals('60'));
      },
    );

    test(
      'Given class code with explicit parameter types and simple formal parameters, '
      'When visiting the AST, '
      'Then it should extract parameters with correct types and ignore key parameter',
      () {
        // Given
        const code = '''
          class AuthService {
            AuthService(String token, {required bool rememberMe, Key? key});
          }
        ''';

        final parseResult = parseString(content: code);
        final visitor = ConstructorParamVisitor();

        // When
        parseResult.unit.visitChildren(visitor);

        // Then
        expect(visitor.className, equals('AuthService'));
        expect(visitor.parameters.length, equals(2));

        expect(visitor.parameters[0].name, equals('token'));
        expect(visitor.parameters[0].type, equals('String'));
        expect(visitor.parameters[0].isNamed, isFalse);

        expect(visitor.parameters[1].name, equals('rememberMe'));
        expect(visitor.parameters[1].type, equals('bool'));
        expect(visitor.parameters[1].isNamed, isTrue);
      },
    );
  });
}
