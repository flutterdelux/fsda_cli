import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('AppParam', () {
    test('GIVEN valid snake_case appName and workspace parameters '
        'WHEN AppParam primary constructor is called '
        'THEN stores appName and extends WorkspaceParam accurately', () {
      // Given
      const appName = 'portal_app';
      const workspaceName = 'my_workspace';
      const workspacePath = '/projects/my_workspace';

      // When
      const param = AppParam(
        appName: appName,
        workspaceName: workspaceName,
        workspacePath: workspacePath,
      );

      // Then
      expect(param, isA<WorkspaceParam>());
      expect(param.appName, appName);
      expect(param.workspaceName, workspaceName);
      expect(param.workspacePath, workspacePath);
    });

    test('GIVEN a WorkspaceParam instance and snake_case appName '
        'WHEN AppParam.fromWorkspace factory is called '
        'THEN copies workspace properties and sets appName accurately', () {
      // Given
      const workspace = WorkspaceParam(
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );
      const appName = 'portal_app';

      // When
      final param = AppParam.fromWorkspace(
        workspace: workspace,
        appName: appName,
      );

      // Then
      expect(param.appName, appName);
      expect(param.workspaceName, workspace.workspaceName);
      expect(param.workspacePath, workspace.workspacePath);
    });
  });
}
