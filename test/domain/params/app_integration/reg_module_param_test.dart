import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('RegModuleParam', () {
    test(
      'GIVEN valid moduleName, appName, and workspace parameters '
      'WHEN RegModuleParam constructor is called '
      'THEN stores all properties accurately and satisfies AppParam, ModuleParam, and WorkspaceParam types',
      () {
        // Given
        const moduleName = 'authentication';
        const appName = 'portal_app';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = RegModuleParam(
          moduleName: moduleName,
          appName: appName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
        );

        // Then
        expect(param, isA<AppParam>());
        expect(param, isA<ModuleParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.moduleName, moduleName);
        expect(param.appName, appName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );
  });
}
