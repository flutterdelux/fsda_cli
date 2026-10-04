import '../../generators/composition/compose_generator.dart';
import 'compose_base_command.dart';

class ComposeActionCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposeActionCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-action';

  @override
  final String description =
      'Compose action slice into target page logic/listeners only (manual widget placement, optional route sync via --route).';

  @override
  String get invocation =>
      'fsda compose-action <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route] [--strict]';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeAction(args);
  }
}
