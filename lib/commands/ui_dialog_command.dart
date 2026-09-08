import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiDialogCommand extends UiBaseCommand {
  UiDialogCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.dialog;

  @override
  final String name = 'ui-dialog';

  @override
  final String description =
      'Generate Dialog UI template and inject its ARB/export manifest.';
}
