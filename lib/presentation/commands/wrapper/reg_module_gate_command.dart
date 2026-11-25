import '../../../core/extensions/app_param_x.dart';
import '../../../core/extensions/arg_results_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../domain/params/app_integration/reg_module_param.dart';
import '../../../domain/params/workspace_param.dart';
import '../../resolvers/reg_module_resolver.dart';
import 'workspace_guard_command.dart';

abstract class RegModuleGateCommand extends WorkspaceGuardCommand {
  RegModuleGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      RegModuleResolverKeys.app,
      abbr: 'a',
      help: 'The target app name under apps/.',
    );
    argParser.addOption(
      RegModuleResolverKeys.module,
      abbr: 'm',
      help: 'The target module name under modules/.',
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

    final RegModuleParam param;
    try {
      param = RegModuleResolver.resolve(
        workspace: workspace,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!await directoryService.exists(param.appPath)) {
      logger.error('App "${param.appName}" not found at ${param.appPath}');
      return errorUsage;
    }

    if (!await directoryService.exists(param.modulePath)) {
      logger.error(
        'Module "${param.moduleName}" not found at ${param.modulePath}',
      );
      return errorUsage;
    }

    return handleRegModule(param);
  }

  Future<int> handleRegModule(RegModuleParam regModule);
}
