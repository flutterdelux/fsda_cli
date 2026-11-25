import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/slice_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('SliceGateParam', () {
    test(
      'GIVEN valid slice and feature hierarchy parameters '
      'WHEN SliceGateParam primary constructor is called '
      'THEN stores slice and extends FeatureParam, ModuleParam, and WorkspaceParam',
      () {
        // Given
        const slice = 'task_list';
        const featureName = 'task';
        const moduleName = 'project_management';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = SliceParam(
          sliceName: slice,
          featureName: featureName,
          moduleName: moduleName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<FeatureParam>());
        expect(param, isA<ModuleParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.sliceName, slice);
        expect(param.featureName, featureName);
        expect(param.moduleName, moduleName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );

    test(
      'GIVEN a FeatureParam instance and slice name '
      'WHEN SliceGateParam.fromFeature factory is called '
      'THEN copies feature hierarchy properties and sets slice accurately',
      () {
        // Given
        const feature = FeatureParam(
          featureName: 'payment',
          moduleName: 'billing',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );
        const slice = 'checkout_summary';

        // When
        final param = SliceParam.fromFeature(
          feature: feature,
          sliceName: slice,
        );

        // Then
        expect(param.sliceName, slice);
        expect(param.featureName, feature.featureName);
        expect(param.moduleName, feature.moduleName);
        expect(param.workspaceName, feature.workspaceName);
        expect(param.workspacePath, feature.workspacePath);
      },
    );
  });
}
