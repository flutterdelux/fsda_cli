import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:fsda_cli/domain/params/gen_app_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('GenAppParam', () {
    test(
      'GIVEN valid application generation and workspace parameters '
      'WHEN GenAppParam primary constructor is called '
      'THEN stores all properties and extends AppParam and WorkspaceParam',
      () {
        // Given
        const appName = 'portal_app';
        const org = 'com.fdelux';
        const appTitle = 'Portal App';
        const orgName = 'Flutter Delux';
        const workspaceName = 'my_workspace';
        const workspacePath = '/projects/my_workspace';

        // When
        const param = GenAppParam(
          org: org,
          appTitle: appTitle,
          orgName: orgName,
          workspaceName: workspaceName,
          workspacePath: workspacePath,
          appName: appName,
        );

        // Then
        expect(param, isA<AppParam>());
        expect(param, isA<WorkspaceParam>());
        expect(param.appName, appName);
        expect(param.org, org);
        expect(param.appTitle, appTitle);
        expect(param.orgName, orgName);
        expect(param.workspaceName, workspaceName);
        expect(param.workspacePath, workspacePath);
      },
    );

    test(
      'GIVEN an AppParam instance and application generation details '
      'WHEN GenAppParam.fromApp factory is called '
      'THEN copies app and workspace properties and sets GenAppParam fields accurately',
      () {
        // Given
        const app = AppParam(
          appName: 'portal_app',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );
        const appTitle = 'Portal App';
        const org = 'com.fdelux';
        const orgName = 'Flutter Delux';

        // When
        final param = GenAppParam.fromApp(
          app: app,
          appTitle: appTitle,
          org: org,
          orgName: orgName,
        );

        // Then
        expect(param.appName, app.appName);
        expect(param.workspaceName, app.workspaceName);
        expect(param.workspacePath, app.workspacePath);
        expect(param.appTitle, appTitle);
        expect(param.org, org);
        expect(param.orgName, orgName);
      },
    );
  });
}
