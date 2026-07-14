import '../generators/compose_generator.dart';
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
      'Compose slice as main page scaffold (view-based) and update base route.';

  @override
  String get invocation =>
      'fsda compose-main <slice> -f <feature> -m <module> -a <app> -p <target_page>';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeMain(args);
  }
}
