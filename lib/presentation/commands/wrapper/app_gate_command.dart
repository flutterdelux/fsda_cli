import '../../../core/extensions/app_param_x.dart';
import '../../../core/extensions/arg_results_x.dart';
import '../../../domain/params/app_param.dart';
import '../../../domain/params/workspace_param.dart';
import '../../resolvers/app_resolver.dart';
import 'workspace_guard_command.dart';

abstract class AppGateCommand extends WorkspaceGuardCommand {
  AppGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      AppResolverKeys.app,
      abbr: 'a',
      help: 'Target app name under apps/.',
    );
  }

  @override
  Future<int> handle(WorkspaceParam workspace) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    AppParam app;
    try {
      app = AppResolver.resolve(
        workspace: workspace,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      if (e is FormatException) {
        logger.error(e.message);
      } else {
        logger.error(e.toString());
      }
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final appFound = await directoryService.exists(app.appPath);

    if (appShouldExists && !appFound) {
      logger.error('App "${app.appName}" not found at ${app.appPath}');
      return errorUsage;
    }

    if (!appShouldExists && appFound) {
      logger.error('App "${app.appName}" already exists at ${app.appPath}');
      return errorUsage;
    }

    return handleAppGate(app);
  }

  bool get appShouldExists;

  Future<int> handleAppGate(AppParam app);
}
