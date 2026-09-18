import '../../enums/input_code.dart';
import 'input_base_command.dart';

class InputPasswordCommand extends InputBaseCommand {
  InputPasswordCommand({
    required super.inputGenerator,
    required super.workspaceService,
  });

  @override
  InputCode get inputCode => InputCode.password;

  @override
  final String name = 'input-password';

  @override
  final String description =
      'Generate shared password field widget with visibility toggle and inject ARB hint/invalid keys.';
}
