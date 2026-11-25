import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('RegFeatureParam', () {
    test(
      'GIVEN valid featureName, moduleName, appName, and workspace parameters '
      'WHEN RegFeatureParam constructor is called '
      'THEN stores all properties accurately and satisfies RegModuleParam, FeatureParam, ModuleParam, AppParam, and WorkspaceParam types',
      () {
        // Given
        const featureName = 'login';
        const moduleName = 'authentication';
        const appName = 'portal_app';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = RegFeatureParam(
          featureName: featureName,
          moduleName: moduleName,
          appName: appName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<RegModuleParam>());
        expect(param, isA<FeatureParam>());
        expect(param, isA<ModuleParam>());
        expect(param, isA<AppParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.featureName, featureName);
        expect(param.moduleName, moduleName);
        expect(param.appName, appName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );
  });
}
