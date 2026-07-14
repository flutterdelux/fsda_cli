abstract final class CliMessages {
  static String notInsideWorkspace(String commandName) =>
      '''
"fsda $commandName" command only works inside a FSDA workspace.

Solution:
1. Navigate to your workspace folder (cd <workspace_name>)
2. Or create a new workspace with: fsda create <workspace_name>
''';

  static String appGeneratedNextSteps(String appName) =>
      '''
----------------------------------------
Next steps:
1. Navigate to the app directory: cd apps/$appName
2. Edit apps/$appName/package_rename_config.yaml to set your app's package name (App ID)
3. Run the package rename script: dart run package_rename
4. Edit app launcher icons:
   - apps/$appName/assets/images/launcher-icon-foreground.png
   - apps/$appName/assets/images/launcher-icon.png
5. Edit apps/$appName/flutter_launcher_icons.yaml to set your app's launcher icon configuration
6. Run the flutter_launcher_icons package: dart run flutter_launcher_icons
7. Edit app logo:
   - apps/$appName/assets/images/logo.png
8. Run the app: flutter run
-----------------------------------------''';

  static String workspaceCreatedNextSteps(String workspaceName) =>
      '''------------------------------------------------------------
Next steps:
1. Navigate to the workspace folder: cd $workspaceName
2. Open the configuration file: fsda.yaml
3. Select the packages you want to use under the "packages:" key (Uncomment the packages you want to use and comment out the ones you don't)
4. Execute the synchronization: fsda configure
------------------------------------------------------------''';
}
