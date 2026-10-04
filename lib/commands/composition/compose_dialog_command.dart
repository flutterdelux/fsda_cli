import '../../generators/composition/compose_generator.dart';
import 'compose_base_command.dart';

class ComposeDialogCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposeDialogCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-dialog';

  @override
  final String description =
      'Compose slice as dialog-first action scaffold with internal logic providers/listeners (route sync optional via --route).';

  @override
  String get invocation =>
      'fsda compose-dialog <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route] [--strict]';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeDialog(args);
  }
}
