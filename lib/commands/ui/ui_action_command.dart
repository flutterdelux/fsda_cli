import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiActionCommand extends UiBaseCommand {
  UiActionCommand({
    required super.uiGenerator,
    required super.workspaceService,
  });

  @override
  UiCode get uiTemplate => UiCode.action;

  @override
  final String name = 'ui-action';

  @override
  final String description =
      'Generate Action Button UI template and inject its ARB/export manifest.';
}
