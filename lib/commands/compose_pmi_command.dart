import '../generators/compose_generator.dart';
import 'compose_base_command.dart';

class ComposePmiCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposePmiCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-pmi';

  @override
  final String description =
      'Compose popup menu item slice into existing target page actions and inject related logic/listeners.';

  @override
  String get invocation =>
      'fsda compose-pmi <slice> -f <feature> -m <module> -a <app> -p <target_page>';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composePmi(args);
  }
}
