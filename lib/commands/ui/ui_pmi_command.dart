import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiPmiCommand extends UiBaseCommand {
  UiPmiCommand({required super.uiGenerator, required super.workspaceService});

  @override
  UiCode get uiTemplate => UiCode.pmi;

  @override
  final String name = 'ui-pmi';

  @override
  final String description =
      'Generate Popup Menu Item UI template and inject its ARB/export manifest.';
}
