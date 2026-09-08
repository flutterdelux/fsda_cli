import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiMainCommand extends UiBaseCommand {
  UiMainCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.main;

  @override
  final String name = 'ui-main';

  @override
  final String description =
      'Generate Main Content UI template and inject its ARB/export manifest.';
}
