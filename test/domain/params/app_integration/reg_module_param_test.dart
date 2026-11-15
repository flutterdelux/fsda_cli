import 'package:fsda_cli/domain/params/app_integration/app_integration_param.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:test/test.dart';

void main() {
  group('RegModuleParam', () {
    test(
      'Given app name, app path, module name, module path, and optional feature fields, '
      'When RegModuleParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties',
      () {
        // Arrange (Given)
        const appName = 'my_app';
        const appPath = '/workspace/apps/my_app';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';

        // Act (When)
        const regModuleParam = RegModuleParam(
          appName: appName,
          appPath: appPath,
          moduleName: moduleName,
          modulePath: modulePath,
          featureName: featureName,
          featurePath: featurePath,
        );

        // Assert (Then)
        expect(regModuleParam.appName, equals(appName));
        expect(regModuleParam.appPath, equals(appPath));
        expect(regModuleParam.moduleName, equals(moduleName));
        expect(regModuleParam.modulePath, equals(modulePath));
        expect(regModuleParam.featureName, equals(featureName));
        expect(regModuleParam.featurePath, equals(featurePath));
      },
    );

    test(
      'Given an AppIntegrationParam instance, '
      'When RegModuleParam.fromAppIntegration factory is called, '
      'Then it correctly maps all properties from the base integration parameter',
      () {
        // Arrange (Given)
        const appIntegrationParam = AppIntegrationParam(
          appName: 'shop_app',
          appPath: '/workspace/apps/shop_app',
          moduleName: 'cart',
          modulePath: '/workspace/modules/cart',
          featureName: 'checkout',
          featurePath: '/workspace/modules/cart/lib/src/features/checkout',
        );

        // Act (When)
        final regModuleParam = RegModuleParam.fromAppIntegration(
          appIntegrationParam,
        );

        // Assert (Then)
        expect(regModuleParam.appName, equals(appIntegrationParam.appName));
        expect(regModuleParam.appPath, equals(appIntegrationParam.appPath));
        expect(
          regModuleParam.moduleName,
          equals(appIntegrationParam.moduleName),
        );
        expect(
          regModuleParam.modulePath,
          equals(appIntegrationParam.modulePath),
        );
        expect(
          regModuleParam.featureName,
          equals(appIntegrationParam.featureName),
        );
        expect(
          regModuleParam.featurePath,
          equals(appIntegrationParam.featurePath),
        );
      },
    );
  });
}
