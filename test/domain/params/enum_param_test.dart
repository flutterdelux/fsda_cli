import 'package:fsda_cli/domain/params/enum_param.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('EnumParam', () {
    test(
      'GIVEN valid enum and feature hierarchy parameters '
      'WHEN EnumParam primary constructor is called '
      'THEN stores all properties accurately and extends FeatureParam hierarchy',
      () {
        // Given
        const enumName = 'task_status';
        const values = ['todo', 'in_progress', 'completed'];
        const isLower = true;
        const featureName = 'task';
        const moduleName = 'project_management';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = EnumParam(
          enumName: enumName,
          values: values,
          isLower: isLower,
          featureName: featureName,
          moduleName: moduleName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<FeatureParam>());
        expect(param, isA<ModuleParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.enumName, enumName);
        expect(param.values, values);
        expect(param.isLower, isTrue);
        expect(param.featureName, featureName);
        expect(param.moduleName, moduleName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );

    test(
      'GIVEN a FeatureParam instance and enum details '
      'WHEN EnumParam.fromFeature factory is called '
      'THEN copies feature hierarchy properties and sets enum fields accurately',
      () {
        // Given
        const feature = FeatureParam(
          featureName: 'payment',
          moduleName: 'billing',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );
        const enumName = 'payment_method';
        const values = ['credit_card', 'bank_transfer', 'e_wallet'];
        const isLower = false;

        // When
        final param = EnumParam.fromFeature(
          feature: feature,
          enumName: enumName,
          values: values,
          isLower: isLower,
        );

        // Then
        expect(param.enumName, enumName);
        expect(param.values, values);
        expect(param.isLower, isFalse);
        expect(param.featureName, feature.featureName);
        expect(param.moduleName, feature.moduleName);
        expect(param.workspaceName, feature.workspaceName);
        expect(param.workspacePath, feature.workspacePath);
      },
    );
  });
}
