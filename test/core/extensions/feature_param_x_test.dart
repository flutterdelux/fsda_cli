import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FeatureParamX', () {
    const param = FeatureParam(
      featureName: 'order_history',
      moduleName: 'transaction',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );

    test(
      'GIVEN a FeatureParam instance with snake_case featureName '
      'WHEN case-conversion getters are accessed '
      'THEN returns snake_case, camelCase, PascalCase, and Title Case variants accurately',
      () {
        // When & Then
        expect(param.featureSnake, 'order_history');
        expect(param.featureCamel, 'orderHistory');
        expect(param.featurePascal, 'OrderHistory');
        expect(param.featureTitle, 'Order History');
      },
    );

    test(
      'GIVEN a FeatureParam instance '
      'WHEN path getters are accessed '
      'THEN returns accurate feature, barrel, repository interface, and repository implementation paths',
      () {
        // Given
        final expectedFeaturePath = p.join(
          '/projects/my_workspace',
          'modules',
          'transaction',
          'lib',
          'src',
          'features',
          'order_history',
        );

        // When & Then
        expect(param.featurePath, expectedFeaturePath);
        expect(
          param.featureBarrelPath,
          p.join(expectedFeaturePath, 'order_history_feature.dart'),
        );
        expect(
          param.repoInterfacePath,
          p.join(
            expectedFeaturePath,
            'domain',
            'repositories',
            'order_history_repository.dart',
          ),
        );
        expect(
          param.repoImplPath,
          p.join(
            expectedFeaturePath,
            'data',
            'repositories',
            'order_history_repository_impl.dart',
          ),
        );
      },
    );
  });
}
