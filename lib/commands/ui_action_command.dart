import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiActionCommand extends UiBaseCommand {
  UiActionCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.action;

  @override
  final String name = 'ui-action';

  @override
  final String description =
      'Generate Action Button UI template and inject its ARB/export manifest.';
}
