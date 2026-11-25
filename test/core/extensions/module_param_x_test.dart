import 'package:fsda_cli/core/extensions/module_param_x.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ModuleParamX', () {
    const param = ModuleParam(
      moduleName: 'user_profile',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );

    test(
      'GIVEN a ModuleParam instance with snake_case moduleName '
      'WHEN case-conversion getters are accessed '
      'THEN returns snake_case, camelCase, and PascalCase variants accurately',
      () {
        // When & Then
        expect(param.moduleSnake, 'user_profile');
        expect(param.moduleCamel, 'userProfile');
        expect(param.modulePascal, 'UserProfile');
      },
    );

    test('GIVEN a ModuleParam instance '
        'WHEN path getters are accessed '
        'THEN returns accurate modulePath and moduleBarrelPath', () {
      // Given
      final expectedModulePath = p.join(
        '/projects/my_workspace',
        'modules',
        'user_profile',
      );

      // When & Then
      expect(param.modulePath, expectedModulePath);
      expect(
        param.moduleBarrelPath,
        p.join(expectedModulePath, 'lib', 'user_profile.dart'),
      );
    });
  });
}
