import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('WorkspaceParam', () {
    test('GIVEN valid workspaceName and workspacePath '
        'WHEN WorkspaceParam is instantiated '
        'THEN stores all property values accurately', () {
      // Given
      const workspaceName = 'my_workspace';
      const workspacePath = '/projects/my_workspace';

      // When
      const param = WorkspaceParam(
        workspaceName: workspaceName,
        workspacePath: workspacePath,
      );

      // Then
      expect(param.workspaceName, workspaceName);
      expect(param.workspacePath, workspacePath);
    });
  });
}
