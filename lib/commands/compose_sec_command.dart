import '../generators/compose_generator.dart';
import 'compose_base_command.dart';

class ComposeSecCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposeSecCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-sec';

  @override
  final String description =
      'Compose section slice by injecting provider with auto-bootstrap, execution trigger, and generated section method; section placement is manual.';

  @override
  String get invocation =>
      'fsda compose-sec <slice> -f <feature> -m <module> -a <app> -p <target_page>';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeSec(args);
  }
}
