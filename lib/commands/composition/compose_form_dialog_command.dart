import '../../generators/composition/compose_generator.dart';
import 'compose_base_command.dart';

class ComposeFormDialogCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposeFormDialogCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-form-dialog';

  @override
  final String description =
      'Compose slice as form dialog page scaffold (dialog-based) for showDialog() usage (route sync optional via --route).';

  @override
  String get invocation =>
      'fsda compose-form-dialog <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeFormDialog(args);
  }
}
