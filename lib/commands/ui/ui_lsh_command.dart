import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiLshCommand extends UiBaseCommand {
  UiLshCommand({required super.uiGenerator, required super.workspaceService});

  @override
  UiCode get uiTemplate => UiCode.lsh;

  @override
  final String name = 'ui-lsh';

  @override
  final String description =
      'Generate List Horizontal UI template and inject its ARB/export manifest.';
}
