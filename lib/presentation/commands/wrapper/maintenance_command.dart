import 'package:path/path.dart' as p;

import '../../../core/constants/rules.dart';
import '../../../domain/models/target_maintenance_model.dart';
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
  Future<int> handle() async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final moduleName = argResults?['module'] as String?;
    final appProjectName = argResults?['app'] as String?;

    if (moduleName == null && appProjectName == null) {
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

    if (appProjectName != null) {
      if (!Rules.appProjectNameRegExp.hasMatch(appProjectName)) {
        logger.error('Invalid app project name: "$appProjectName".');
        logger.log(Rules.appProjectNameDescription);
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      final appProjectPath = p.join(
        directoryService.currentPath,
        'apps',
        appProjectName,
      );
      if (!await directoryService.exists(appProjectPath)) {
        logger.error('App "$appProjectName" not found at $appProjectPath');
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      targets.add(
        TargetMaintenanceModel(
          type: .app,
          name: appProjectName,
          path: appProjectPath,
        ),
      );
    }

    return handleMaintenance(targets);
  }

  Future<int> handleMaintenance(List<TargetMaintenanceModel> targets);
}
