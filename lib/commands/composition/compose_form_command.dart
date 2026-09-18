import '../../generators/composition/compose_generator.dart';
import 'compose_base_command.dart';

class ComposeFormCommand extends ComposeBaseCommand {
  final ComposeGenerator composeGenerator;

  ComposeFormCommand({
    required this.composeGenerator,
    required super.workspaceService,
  });

  @override
  final String name = 'compose-form';

  @override
  final String description =
      'Compose slice as form page scaffold (view + form handling, route sync optional via --route).';

  @override
  String get invocation =>
      'fsda compose-form <slice> -f <feature> -m <module> -a <app> -p <target_page> [--route] [--strict]';

  @override
  Future<void> runValidated(args) async {
    await composeGenerator.composeForm(args);
  }
}
