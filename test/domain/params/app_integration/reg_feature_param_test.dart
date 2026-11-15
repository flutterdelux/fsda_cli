import 'package:fsda_cli/domain/params/app_integration/app_integration_param.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:test/test.dart';

void main() {
  group('RegFeatureParam', () {
    test(
      'Given app name, app path, module name, module path, feature name, and feature path, '
      'When RegFeatureParam is instantiated directly via constructor, '
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
        const regFeatureParam = RegFeatureParam(
          appName: appName,
          appPath: appPath,
          moduleName: moduleName,
          modulePath: modulePath,
          featureName: featureName,
          featurePath: featurePath,
        );

        // Assert (Then)
        expect(regFeatureParam.appName, equals(appName));
        expect(regFeatureParam.appPath, equals(appPath));
        expect(regFeatureParam.moduleName, equals(moduleName));
        expect(regFeatureParam.modulePath, equals(modulePath));
        expect(regFeatureParam.featureName, equals(featureName));
        expect(regFeatureParam.featurePath, equals(featurePath));
      },
    );

    test(
      'Given an AppIntegrationParam instance, '
      'When RegFeatureParam.fromAppIntegration factory is called, '
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
        final regFeatureParam = RegFeatureParam.fromAppIntegration(
          appIntegrationParam,
        );

        // Assert (Then)
        expect(regFeatureParam.appName, equals(appIntegrationParam.appName));
        expect(regFeatureParam.appPath, equals(appIntegrationParam.appPath));
        expect(
          regFeatureParam.moduleName,
          equals(appIntegrationParam.moduleName),
        );
        expect(
          regFeatureParam.modulePath,
          equals(appIntegrationParam.modulePath),
        );
        expect(
          regFeatureParam.featureName,
          equals(appIntegrationParam.featureName),
        );
        expect(
          regFeatureParam.featurePath,
          equals(appIntegrationParam.featurePath),
        );
      },
    );
  });
}
