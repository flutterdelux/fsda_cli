import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/params/ds_param.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/local_ds_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('LocalDsParam', () {
    group('Primary Constructor', () {
      test('GIVEN valid cacheKey and feature hierarchy parameters '
          'WHEN LocalDsParam primary constructor is called '
          'THEN sets mode to DsMode.local and extends DsParam hierarchy', () {
        // Given
        const cacheKey = 'auth_token';
        const featureName = 'auth';
        const moduleName = 'identity';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = LocalDsParam(
          cacheKey: cacheKey,
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
        expect(param.mode, DsMode.local);
        expect(param.cacheKey, cacheKey);
        expect(param.featureName, featureName);
        expect(param.moduleName, moduleName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      });
    });

    group('LocalDsParam.fromFeature Factory', () {
      test(
        'GIVEN a FeatureParam instance and cacheKey '
        'WHEN LocalDsParam.fromFeature factory is called '
        'THEN copies feature hierarchy properties and sets mode to DsMode.local',
        () {
          // Given
          const baseFeature = FeatureParam(
            featureName: 'task',
            moduleName: 'project_management',
            workspaceName: 'my_workspace',
            workspacePath: '/projects/my_workspace',
          );
          const cacheKey = 'cached_tasks';

          // When
          final param = LocalDsParam.fromFeature(
            feature: baseFeature,
            cacheKey: cacheKey,
          );

          // Then
          expect(param.mode, DsMode.local);
          expect(param.cacheKey, cacheKey);
          expect(param.featureName, baseFeature.featureName);
          expect(param.moduleName, baseFeature.moduleName);
          expect(param.workspaceName, baseFeature.workspaceName);
          expect(param.workspacePath, baseFeature.workspacePath);
        },
      );
    });
  });
}
