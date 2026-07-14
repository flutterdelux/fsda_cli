import 'package:args/command_runner.dart';
import '../constants/cli_rules.dart';
import '../generators/workspace_generator.dart';

class CreateCommand extends Command {
  final WorkspaceGenerator workspaceGenerator;

  CreateCommand({required this.workspaceGenerator});

  @override
  String get description => 'Creates a new workspace or project.';

  @override
  String get name => 'create';

  @override
  String get invocation => 'fsda create <workspace_name>';

  @override
  Future<void> run() async {
    final args = argResults!.rest;

    if (args.isEmpty) {
      throw UsageException('Missing workspace name', usage);
    }

    if (args.length > 1) {
      throw UsageException(
        'Invalid workspace name. Workspace name should not contain spaces.\n',
        usage,
      );
    }

    final workspaceName = args[0];

    final namePattern = RegExp(CliRules.workspaceNamePattern);
    if (!namePattern.hasMatch(workspaceName)) {
      throw UsageException(
        'Invalid workspace name.\n'
        '${CliRules.workspaceNameRule}',
        usage,
      );
    }

    await workspaceGenerator.generate(workspaceName);
  }
}
