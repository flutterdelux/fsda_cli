import 'package:fsda_cli/core/extensions/failure_param_x.dart';
import 'package:fsda_cli/domain/params/failure_param.dart';
import 'package:test/test.dart';

void main() {
  group('FailureParamX Tests', () {
    test(
      'should generate correct shared error paths based on moduleName and modulePath',
      () {
        const param = FailureParam(
          moduleName: 'auth',
          modulePath: '/modules/auth',
          name: 'invalid_credentials',
          message: 'Invalid credentials provided',
        );

        expect(
          param.exceptionPath,
          '/modules/auth/lib/src/shared/data/errors/auth_exception.dart',
        );
        expect(
          param.failurePath,
          '/modules/auth/lib/src/shared/domain/errors/auth_failure.dart',
        );
        expect(
          param.extensionPath,
          '/modules/auth/lib/src/shared/ui/extensions/auth_failure_x.dart',
        );
      },
    );

    test('should format name casing and uppercase code correctly', () {
      const param = FailureParam(
        moduleName: 'auth',
        modulePath: '/modules/auth',
        name: 'token_expired',
        message: 'Token has expired',
      );

      expect(param.nameSnake, 'token_expired');
      expect(param.nameCamel, 'tokenExpired');
      expect(param.namePascal, 'TokenExpired');
      expect(param.nameCode, 'TOKEN_EXPIRED');
    });
  });
}
