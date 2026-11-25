import 'package:fsda_cli/domain/params/failure_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('FailureParam', () {
    test(
      'GIVEN valid failure and module parameters '
      'WHEN FailureParam primary constructor is called '
      'THEN stores all properties and extends ModuleParam and WorkspaceParam',
      () {
        // Given
        const name = 'invalid_payment_method';
        const message = 'The selected payment method is not supported.';
        const moduleName = 'payment';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = FailureParam(
          name: name,
          message: message,
          moduleName: moduleName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<ModuleParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.name, name);
        expect(param.message, message);
        expect(param.moduleName, moduleName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );

    test(
      'GIVEN a ModuleParam instance, snake_case name, and sentence case message '
      'WHEN FailureParam.fromModule factory is called '
      'THEN copies module and workspace properties and sets name and message accurately',
      () {
        // Given
        const module = ModuleParam(
          moduleName: 'authentication',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );
        const name = 'email_is_required';
        const message = 'Email address cannot be empty.';

        // When
        final param = FailureParam.fromModule(
          module: module,
          name: name,
          message: message,
        );

        // Then
        expect(param.name, name);
        expect(param.message, message);
        expect(param.moduleName, module.moduleName);
        expect(param.workspaceName, module.workspaceName);
        expect(param.workspacePath, module.workspacePath);
      },
    );
  });
}
