import '../../../core/extensions/arg_results_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../domain/params/module_param.dart';
import '../../../domain/params/workspace_param.dart';
import '../../resolvers/module_resolver.dart';
import 'workspace_guard_command.dart';

abstract class ModuleGateCommand extends WorkspaceGuardCommand {
  ModuleGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      ModuleResolverKeys.module,
      abbr: 'm',
      help: 'Target module name under modules/.',
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

    ModuleParam module;
    try {
      module = ModuleResolver.resolve(
        workspace: workspace,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final moduleFound = await directoryService.exists(module.modulePath);

    if (moduleShouldExists && !moduleFound) {
      logger.error(
        'Module "${module.moduleName}" not found at ${module.modulePath}',
      );
      return errorUsage;
    }

    if (!moduleShouldExists && moduleFound) {
      logger.error(
        'Module "${module.moduleName}" already exists at ${module.modulePath}',
      );
      return errorUsage;
    }

    return handleModuleGate(module);
  }

  bool get moduleShouldExists;

  Future<int> handleModuleGate(ModuleParam module);
}
