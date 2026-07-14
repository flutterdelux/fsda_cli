import '../generators/compose_generator.dart';
import 'compose_base_command.dart';

class ComposePagCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposePagCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-pag';

  @override
  final String description =
      'Compose slice as pagination page scaffold with pagination-specific state handling.';

  @override
  String get invocation =>
      'fsda compose-pag <slice> -f <feature> -m <module> -a <app> -p <target_page>';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composePag(args);
  }
}
