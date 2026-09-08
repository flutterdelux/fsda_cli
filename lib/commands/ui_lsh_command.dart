import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiLshCommand extends UiBaseCommand {
  UiLshCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.lsh;

  @override
  final String name = 'ui-lsh';

  @override
  final String description =
      'Generate List Horizontal UI template and inject its ARB/export manifest.';
}
