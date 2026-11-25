import 'package:fsda_cli/core/extensions/reg_module_param_x.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('RegModuleParamX', () {
    const param = RegModuleParam(
      appName: 'portal_app',
      moduleName: 'authentication',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );

    final expectedAppPath = p.join(
      '/projects/my_workspace',
      'apps',
      'portal_app',
    );

    test('GIVEN a RegModuleParam instance '
        'WHEN appPubspecPath getter is accessed '
        'THEN returns joined pubspec.yaml path under appPath', () {
      // When & Then
      expect(param.appPubspecPath, p.join(expectedAppPath, 'pubspec.yaml'));
    });

    test(
      'GIVEN a RegModuleParam instance '
      'WHEN module structure path getters are accessed '
      'THEN returns accurate appModulePath, appModuleDiPath, and appModuleRoutePath',
      () {
        // Given
        final expectedAppModulePath = p.join(
          expectedAppPath,
          'lib',
          'modules',
          'authentication',
        );

        // When & Then
        expect(param.appModulePath, expectedAppModulePath);
        expect(
          param.appModuleDiPath,
          p.join(expectedAppModulePath, 'authentication_di.dart'),
        );
        expect(
          param.appModuleRoutePath,
          p.join(expectedAppModulePath, 'authentication_route.dart'),
        );
      },
    );

    test(
      'GIVEN a RegModuleParam instance '
      'WHEN module injection path getters are accessed '
      'THEN returns accurate mainAppPath, failureXPath, appDiPath, and appRouterPath',
      () {
        // When & Then
        expect(
          param.mainAppPath,
          p.join(expectedAppPath, 'lib', 'app', 'main_app.dart'),
        );
        expect(
          param.failureXPath,
          p.join(
            expectedAppPath,
            'lib',
            'core',
            'extensions',
            'failure_x.dart',
          ),
        );
        expect(
          param.appDiPath,
          p.join(expectedAppPath, 'lib', 'core', 'di', 'di.dart'),
        );
        expect(
          param.appRouterPath,
          p.join(expectedAppPath, 'lib', 'app', 'app_router.dart'),
        );
      },
    );
  });
}
