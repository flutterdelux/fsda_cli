import 'package:path/path.dart' as p;

import '../../../core/constants/rules.dart';
import '../../../domain/params/module_gate_param.dart';
import 'workspace_guard_command.dart';

abstract class ModuleGateCommand extends WorkspaceGuardCommand {
  ModuleGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      'module',
      abbr: 'm',
      help: 'Target module name under modules/.',
    );
  }

  @override
  Future<int> handle() async {
    final moduleArg = argResults?['module'] as String?;

    if (moduleArg == null || moduleArg.isEmpty) {
      logger.error('Missing required options (--module).');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!Rules.moduleRegExp.hasMatch(moduleArg)) {
      logger.error('Invalid module name: "$moduleArg".');
      logger.log(Rules.moduleDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final resolvedModulePath = p.join(
      directoryService.currentPath,
      'modules',
      moduleArg,
    );
    if (!await directoryService.exists(resolvedModulePath)) {
      logger.error('Module "$moduleArg" not found at $resolvedModulePath');
      return errorUsage;
    }

    return handleModuleGate(
      ModuleGateParam(moduleName: moduleArg, modulePath: resolvedModulePath),
    );
  }

  Future<int> handleModuleGate(ModuleGateParam moduleGate);
}
