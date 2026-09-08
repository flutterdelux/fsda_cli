import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiSecCommand extends UiBaseCommand {
  UiSecCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.sec;

  @override
  final String name = 'ui-sec';

  @override
  final String description =
      'Generate Section UI template and inject its ARB/export manifest.';
}
