import 'package:fsda_cli/core/extensions/gen_app_param_x.dart';
import 'package:fsda_cli/domain/params/gen_app_param.dart';
import 'package:test/test.dart';

void main() {
  group('GenAppParamX', () {
    test('GIVEN a GenAppParam instance with snake_case appName '
        'WHEN projectId getter is accessed '
        'THEN returns lowercase string without underscores', () {
      // Given
      const param = GenAppParam(
        appName: 'portal_mobile_app',
        org: 'com.fdelux',
        appTitle: 'Portal Mobile App',
        orgName: 'Flutter Delux',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      // When
      final result = param.projectId;

      // Then
      expect(result, 'portalmobileapp');
    });

    test('GIVEN a GenAppParam instance with single-word appName '
        'WHEN projectId getter is accessed '
        'THEN returns identical lowercase string', () {
      // Given
      const param = GenAppParam(
        appName: 'ruviti',
        org: 'com.ruviti',
        appTitle: 'Ruviti',
        orgName: 'Ruviti Corp',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      // When
      final result = param.projectId;

      // Then
      expect(result, 'ruviti');
    });
  });
}
