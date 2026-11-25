import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('ModuleParam', () {
    test('GIVEN valid module and workspace parameters '
        'WHEN ModuleParam primary constructor is called '
        'THEN stores its own properties and extends WorkspaceParam', () {
      // Given
      const moduleName = 'authentication';
      const workspaceName = 'my_workspace';
      const workspacePath = '/projects/my_workspace';

      // When
      const param = ModuleParam(
        moduleName: moduleName,
        workspaceName: workspaceName,
        workspacePath: workspacePath,
      );

      // Then
      expect(param, isA<WorkspaceParam>());
      expect(param.moduleName, moduleName);
      expect(param.workspaceName, workspaceName);
      expect(param.workspacePath, workspacePath);
    });

    test('GIVEN a WorkspaceParam instance and moduleName '
        'WHEN ModuleParam.fromWorkspace factory is called '
        'THEN copies workspace properties and sets moduleName accurately', () {
      // Given
      const workspace = WorkspaceParam(
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );
      const moduleName = 'user_profile';

      // When
      final param = ModuleParam.fromWorkspace(
        workspace: workspace,
        moduleName: moduleName,
      );

      // Then
      expect(param.moduleName, moduleName);
      expect(param.workspaceName, workspace.workspaceName);
      expect(param.workspacePath, workspace.workspacePath);
    });
  });
}
