import 'package:fsda_cli/core/extensions/app_param_x.dart';
import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('AppParamX', () {
    test('GIVEN an AppParam instance with workspacePath and appName '
        'WHEN appPath getter is accessed '
        'THEN returns joined path under apps directory', () {
      // Given
      const param = AppParam(
        appName: 'portal_app',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      // When
      final result = param.appPath;

      // Then
      expect(result, p.join('/projects/my_workspace', 'apps', 'portal_app'));
    });
  });
}
