import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/params/ds_param.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/remote_ds_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteDsParam', () {
    group('Primary Constructor', () {
      test('GIVEN valid basePath and feature hierarchy parameters '
          'WHEN RemoteDsParam primary constructor is called '
          'THEN sets mode to DsMode.remote and extends DsParam hierarchy', () {
        // Given
        const basePath = '/tasks';
        const featureName = 'task';
        const moduleName = 'project_management';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = RemoteDsParam(
          basePath: basePath,
          featureName: featureName,
          moduleName: moduleName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<DsParam>());
        expect(param, isA<FeatureParam>());
        expect(param, isA<ModuleParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.mode, DsMode.remote);
        expect(param.basePath, basePath);
        expect(param.featureName, featureName);
        expect(param.moduleName, moduleName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      });
    });

    group('RemoteDsParam.fromFeature Factory', () {
      test(
        'GIVEN a FeatureParam instance and basePath '
        'WHEN RemoteDsParam.fromFeature factory is called '
        'THEN copies feature hierarchy properties and sets mode to DsMode.remote',
        () {
          // Given
          const baseFeature = FeatureParam(
            featureName: 'user_profile',
            moduleName: 'account',
            workspaceName: 'my_workspace',
            workspacePath: '/projects/my_workspace',
          );
          const basePath = '/api/v1/profiles';

          // When
          final param = RemoteDsParam.fromFeature(
            feature: baseFeature,
            basePath: basePath,
          );

          // Then
          expect(param.mode, DsMode.remote);
          expect(param.basePath, basePath);
          expect(param.featureName, baseFeature.featureName);
          expect(param.moduleName, baseFeature.moduleName);
          expect(param.workspaceName, baseFeature.workspaceName);
          expect(param.workspacePath, baseFeature.workspacePath);
        },
      );
    });
  });
}
