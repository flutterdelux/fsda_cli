import 'package:path/path.dart' as p;

import '../../../core/constants/rules.dart';
import '../../../domain/models/target_maintenance_model.dart';
import '../../../domain/params/workspace_param.dart';
import 'workspace_guard_command.dart';

abstract class MaintenanceCommand extends WorkspaceGuardCommand {
  MaintenanceCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      'module',
      abbr: 'm',
      help: 'The target module name under modules/.',
    );
    argParser.addOption(
      'app',
      abbr: 'a',
      help: 'The target app name under apps/.',
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

    final moduleName = argResults?['module'] as String?;
    final appName = argResults?['app'] as String?;

    if (moduleName == null && appName == null) {
      logger.error(
        'Please specify at least one target: --module (-m) or --app (-a).',
      );
      logger.error('Usage: $invocation');
      return errorUsage;
    }

    final targets = <TargetMaintenanceModel>[];

    if (moduleName != null) {
      if (!Rules.moduleRegExp.hasMatch(moduleName)) {
        logger.error('Invalid module name: "$moduleName".');
        logger.log(Rules.moduleDescription);
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      final modulePath = p.join(
        directoryService.currentPath,
        'modules',
        moduleName,
      );
      if (!await directoryService.exists(modulePath)) {
        logger.error('Module "$moduleName" not found at $modulePath');
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      targets.add(
        TargetMaintenanceModel(
          type: .module,
          name: moduleName,
          path: modulePath,
        ),
      );
    }

    if (appName != null) {
      if (!Rules.appNameRegExp.hasMatch(appName)) {
        logger.error('Invalid app project name: "$appName".');
        logger.log(Rules.appNameDescription);
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      final appProjectPath = p.join(
        directoryService.currentPath,
        'apps',
        appName,
      );
      if (!await directoryService.exists(appProjectPath)) {
        logger.error('App "$appName" not found at $appProjectPath');
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      targets.add(
        TargetMaintenanceModel(type: .app, name: appName, path: appProjectPath),
      );
    }

    return handleMaintenance(targets);
  }

  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets);
}
