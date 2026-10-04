import '../../generators/composition/compose_generator.dart';
import 'compose_base_command.dart';

class ComposeMainCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposeMainCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-main';

  @override
  final String description =
      'Compose slice as main page scaffold (view-based, route sync optional via --route).';

  @override
  String get invocation =>
      'fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <prefix_target_page> [--route] [--strict]';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeMain(args);
  }
}
