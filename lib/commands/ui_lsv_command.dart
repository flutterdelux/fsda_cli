import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiLsvCommand extends UiBaseCommand {
  UiLsvCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.lsv;

  @override
  final String name = 'ui-lsv';

  @override
  final String description =
      'Generate List Vertical UI template and inject its ARB/export manifest.';
}
