import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('FeatureParam', () {
    test(
      'GIVEN valid feature, module, and workspace parameters '
      'WHEN FeatureParam primary constructor is called '
      'THEN stores all properties and extends ModuleParam and WorkspaceParam',
      () {
        // Given
        const featureName = 'login';
        const moduleName = 'authentication';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = FeatureParam(
          featureName: featureName,
          moduleName: moduleName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<ModuleParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.featureName, featureName);
        expect(param.moduleName, moduleName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );

    test(
      'GIVEN a ModuleParam instance and featureName '
      'WHEN FeatureParam.fromModule factory is called '
      'THEN copies module and workspace properties and sets featureName accurately',
      () {
        // Given
        const module = ModuleParam(
          moduleName: 'payment',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );
        const featureName = 'checkout';

        // When
        final param = FeatureParam.fromModule(
          module: module,
          featureName: featureName,
        );

        // Then
        expect(param.featureName, featureName);
        expect(param.moduleName, module.moduleName);
        expect(param.workspaceName, module.workspaceName);
        expect(param.workspacePath, module.workspacePath);
      },
    );
  });
}
