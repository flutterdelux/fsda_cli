import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiDialogCommand extends UiBaseCommand {
  UiDialogCommand({
    required super.uiGenerator,
    required super.workspaceService,
  });

  @override
  UiCode get uiTemplate => UiCode.dialog;

  @override
  final String name = 'ui-dialog';

  @override
  final String description =
      'Generate Dialog UI template and inject its ARB/export manifest.';
}
