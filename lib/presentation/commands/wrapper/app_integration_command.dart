import 'package:path/path.dart' as p;

import '../../../core/constants/rules.dart';
import '../../../domain/params/app_integration/app_integration_param.dart';
import 'workspace_guard_command.dart';

abstract class AppIntegrationCommand extends WorkspaceGuardCommand {
  AppIntegrationCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The target feature name under module/.',
    );
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

    final appProjectName = argResults?['app'] as String?;

    if (appProjectName == null) {
      logger.error('Target app required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

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

    final moduleName = argResults?['module'] as String?;

    if (moduleName == null) {
      logger.error('Target app required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

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

    final featureName = argResults?['feature'] as String?;
    String? featurePath;
    if (featureName != null) {
      if (!Rules.featureRegExp.hasMatch(featureName)) {
        logger.error('Invalid feature name: "$featureName".');
        logger.log(Rules.featureDescription);
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      featurePath = p.join(modulePath, 'lib', 'src', 'features', featureName);

      if (!await directoryService.exists(featurePath)) {
        logger.error('Feature "$featureName" not found at $featurePath');
        logger.log('Usage: $invocation');
        return errorUsage;
      }
    }

    return handleAppIntegration(
      AppIntegrationParam(
        appName: appProjectName,
        appPath: appProjectPath,
        moduleName: moduleName,
        modulePath: modulePath,
        featureName: featureName,
        featurePath: featurePath,
      ),
    );
  }

  Future<int> handleAppIntegration(AppIntegrationParam appIntegration);
}
