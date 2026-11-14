import 'package:fsda_cli/core/extensions/app_integration_param_x.dart';
import 'package:fsda_cli/domain/params/app_integration/app_integration_param.dart';
import 'package:test/test.dart';

void main() {
  group('AppIntegrationParamX Tests', () {
    test('should format module and feature names with correct casing', () {
      const param = AppIntegrationParam(
        appName: 'MyApp',
        appPath: '/apps/myapp',
        moduleName: 'auth_management',
        modulePath: '/modules/auth_management',
        featureName: 'user_profile',
        featurePath: '/modules/auth_management/lib/src/features/user_profile',
      );

      // Memastikan transformasi casing untuk module berjalan benar
      expect(param.moduleSnake, 'auth_management');
      expect(param.moduleCamel, 'authManagement');
      expect(param.modulePascal, 'AuthManagement');

      // Memastikan transformasi casing untuk feature berjalan benar
      expect(param.featureSnake, 'user_profile');
      expect(param.featureCamel, 'userProfile');
      expect(param.featurePascal, 'UserProfile');
    });

    test('should handle null featureName and featurePath gracefully', () {
      const param = AppIntegrationParam(
        appName: 'MyApp',
        appPath: '/apps/myapp',
        moduleName: 'settings',
        modulePath: '/modules/settings',
        featureName: null,
        featurePath: null,
      );

      // Memastikan nilai null ditangani dengan aman tanpa exception
      expect(param.featureSnake, isNull);
      expect(param.featureCamel, isNull);
      expect(param.featurePascal, isNull);
    });

    test('should generate correct path strings using p.join', () {
      const param = AppIntegrationParam(
        appName: 'MyApp',
        appPath: '/apps/myapp',
        moduleName: 'dashboard',
        modulePath: '/modules/dashboard',
        featureName: null,
        featurePath: null,
      );

      // Memastikan penggabungan path direktori sesuai struktur yang diharapkan
      expect(param.appModulePath, '/apps/myapp/lib/modules/dashboard');
      expect(
        param.appModuleDiPath,
        '/apps/myapp/lib/modules/dashboard/dashboard_di.dart',
      );
      expect(
        param.appModuleRoutePath,
        '/apps/myapp/lib/modules/dashboard/dashboard_route.dart',
      );
      expect(param.mainAppPath, '/apps/myapp/lib/app/main_app.dart');
      expect(
        param.failureXPath,
        '/apps/myapp/lib/core/extensions/failure_x.dart',
      );
      expect(param.appDiPath, '/apps/myapp/lib/core/di/di.dart');
      expect(param.appRouterPath, '/apps/myapp/lib/app/app_router.dart');
    });
  });
}
