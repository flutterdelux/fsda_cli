import '../enums/ui_code.dart';
import '../generators/ui_generator.dart';
import '../services/workspace_service.dart';
import 'ui_base_command.dart';

class UiPagCommand extends UiBaseCommand {
  UiPagCommand({
    required UiGenerator uiGenerator,
    required WorkspaceService workspaceService,
  }) : super(uiGenerator: uiGenerator, workspaceService: workspaceService);

  @override
  UiCode get uiTemplate => UiCode.pag;

  @override
  final String name = 'ui-pag';

  @override
  final String description =
      'Generate Pagination UI template and inject its ARB/export manifest.';
}
