import 'package:path/path.dart' as p;

import '../../domain/models/plan_model.dart';
import '../../domain/params/workspace_param.dart';
import '../../infrastructure/services/apply_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/plan_resolver.dart';
import 'wrapper/workspace_guard_command.dart';

class ApplyCommand extends WorkspaceGuardCommand {
  final ApplyService _applyService;
  final FileService _fileService;

  ApplyCommand({
    required ApplyService applyService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _applyService = applyService,
       _fileService = fileService;

  @override
  String get name => 'apply';

  @override
  String get description =>
      'Applies a declarative YAML plan file to generate code artifacts.';

  @override
  String get invocation => 'fsda $name <path/to/plan.yaml>';

  @override
  Future<int> handle(WorkspaceParam workspace) async {
    final rest = argResults?.rest ?? [];
    if (rest.length != 1) {
      logger.error('Please provide a single path to a YAML plan file.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final rawPath = rest.first.trim();
    final planPath = p.isAbsolute(rawPath)
        ? rawPath
        : p.join(workspace.workspacePath, rawPath);

    if (!await _fileService.exists(planPath)) {
      logger.error('Plan file not found at $planPath');
      return errorUsage;
    }

    final PlanModel plan;
    try {
      final content = await _fileService.readAsString(planPath);
      plan = PlanResolver.resolveYaml(
        yamlContent: content,
        workspace: workspace,
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      return errorUsage;
    }

    final progress = logger.progress(
      'Applying plan ${p.relative(planPath, from: workspace.workspacePath)}...',
    );

    try {
      await _applyService.apply(
        plan: plan,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Plan applied successfully!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Declarative Apply Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to apply plan: $e');
      return errorSystem;
    }
  }
}
