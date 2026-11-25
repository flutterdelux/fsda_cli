import '../../../domain/params/workspace_param.dart';
import '../../../infrastructure/services/helpers/config_service.dart';
import '../../../infrastructure/services/helpers/directory_service.dart';
import '../../../infrastructure/services/helpers/operation_report_service.dart';
import '../../cli_logger.dart';
import 'base_command.dart';

abstract class WorkspaceGuardCommand extends BaseCommand {
  final ConfigService configService;
  final CliLogger logger;
  final OperationReportService reportService;
  final DirectoryService directoryService;

  WorkspaceGuardCommand({
    required this.configService,
    required this.logger,
    required this.reportService,
    required this.directoryService,
  });

  @override
  Future<int> run() async {
    // Workspace Guard terpusat
    final workspace = await configService.fsdaWorkspace;
    if (workspace == null) {
      logger.error(
        'This command must be run inside an FSDA workspace root (where "fsda.yaml" is located).',
      );
      return errorUsage;
    }

    return await handle(workspace);
  }

  /// Metode pengganti `run()` untuk command turunan yang memerlukan workspace root.
  Future<int> handle(WorkspaceParam workspace);
}
