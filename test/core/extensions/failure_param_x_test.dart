import 'package:fsda_cli/core/extensions/failure_param_x.dart';
import 'package:fsda_cli/domain/params/failure_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FailureParamX', () {
    const param = FailureParam(
      name: 'invalid_payment_method',
      message: 'The selected payment method is not supported.',
      moduleName: 'payment',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );

    test(
      'GIVEN a FailureParam instance with snake_case name '
      'WHEN case-conversion getters are accessed '
      'THEN returns snake_case, camelCase, PascalCase, and SCREAMING_SNAKE_CASE variants accurately',
      () {
        // When & Then
        expect(param.nameSnake, 'invalid_payment_method');
        expect(param.nameCamel, 'invalidPaymentMethod');
        expect(param.namePascal, 'InvalidPaymentMethod');
        expect(param.nameScreaming, 'INVALID_PAYMENT_METHOD');
      },
    );

    test(
      'GIVEN a FailureParam instance '
      'WHEN error path getters are accessed '
      'THEN returns accurate exceptionPath, failurePath, and extensionPath under module shared directory',
      () {
        // Given
        final expectedModulePath = p.join(
          '/projects/my_workspace',
          'modules',
          'payment',
        );

        // When & Then
        expect(
          param.exceptionPath,
          p.join(
            expectedModulePath,
            'lib',
            'src',
            'shared',
            'data',
            'errors',
            'payment_exception.dart',
          ),
        );
        expect(
          param.failurePath,
          p.join(
            expectedModulePath,
            'lib',
            'src',
            'shared',
            'domain',
            'errors',
            'payment_failure.dart',
          ),
        );
        expect(
          param.extensionPath,
          p.join(
            expectedModulePath,
            'lib',
            'src',
            'shared',
            'ui',
            'extensions',
            'payment_failure_x.dart',
          ),
        );
      },
    );
  });
}
