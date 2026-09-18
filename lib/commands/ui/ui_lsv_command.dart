import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiLsvCommand extends UiBaseCommand {
  UiLsvCommand({required super.uiGenerator, required super.workspaceService});

  @override
  UiCode get uiTemplate => UiCode.lsv;

  @override
  final String name = 'ui-lsv';

  @override
  final String description =
      'Generate List Vertical UI template and inject its ARB/export manifest.';
}
