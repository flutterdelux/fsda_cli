import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/configure_app_param.dart';
import '../../infrastructure/services/configure_app_service.dart';
import 'wrapper/workspace_guard_command.dart';

class ConfigureAppCommand extends WorkspaceGuardCommand {
  final ConfigureAppService _configureAppService;

  ConfigureAppCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required ConfigureAppService configureAppService,
  }) : _configureAppService = configureAppService;

  @override
  String get name => 'configure-app';

  @override
  String get description =>
      'Generates a new Flutter application project inside apps/ using flutter create and app bundle blueprint.';

  @override
  String get invocation => 'fsda $name <project>';

  @override
  Future<int> handle() async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('App project name is required.\nUsage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid app project name: "$rest".');
      logger.log(Rules.appProjectNameDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final appProjectName = rest.first;
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

    final configureApp = ConfigureAppParam(
      projectName: appProjectName,
      projectPath: appProjectPath,
    );

    final progress = logger.progress('Configure app "$appProjectName"...');

    try {
      await _configureAppService.configure(
        app: configureApp,
        onProgress: (msg) => progress.update(msg),
      );
      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'App Configuration Summary',
      );

      progress.complete(
        'App "$appProjectName" successfully configure under apps/$appProjectName!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate app $appProjectName: $e');
      return errorSystem;
    }
  }
}
