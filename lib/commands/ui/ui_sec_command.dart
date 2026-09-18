import '../../enums/ui_code.dart';
import 'ui_base_command.dart';

class UiSecCommand extends UiBaseCommand {
  UiSecCommand({required super.uiGenerator, required super.workspaceService});

  @override
  UiCode get uiTemplate => UiCode.sec;

  @override
  final String name = 'ui-sec';

  @override
  final String description =
      'Generate Section UI template and inject its ARB/export manifest.';
}
