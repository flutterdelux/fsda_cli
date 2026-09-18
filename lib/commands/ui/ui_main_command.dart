import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiMainCommand extends UiBaseCommand {
  UiMainCommand({required super.uiGenerator, required super.workspaceService});

  @override
  UiCode get uiTemplate => UiCode.main;

  @override
  final String name = 'ui-main';

  @override
  final String description =
      'Generate Main Content UI template and inject its ARB/export manifest.';
}
