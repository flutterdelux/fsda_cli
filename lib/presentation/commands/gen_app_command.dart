import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/app_param.dart';
import '../../infrastructure/services/app_service.dart';
import 'wrapper/workspace_guard_command.dart';

class GenAppCommand extends WorkspaceGuardCommand {
  final AppService _appService;

  GenAppCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required AppService appService,
  }) : _appService = appService {
    argParser.addOption(
      'org',
      help: 'The organization identifier (e.g., com.example).',
      defaultsTo: Rules.orgDefault,
    );
    argParser.addOption('name', help: 'The title or label of the app.');
    argParser.addOption('org-name', help: 'The Organization name.');
  }

  @override
  String get name => 'gen-app';

  @override
  String get description =>
      'Generates a new Flutter application project inside apps/ using flutter create and app bundle blueprint.';

  @override
  String get invocation =>
      'fsda $name <app> [--org <org>] [--name "<App Name>"] [--org-name "<Organization Name>"]';

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

    final org = (argResults?['org'] as String?) ?? Rules.orgDefault;
    if (!Rules.orgRegExp.hasMatch(org)) {
      logger.error('Invalid organization identifier format: "$org".');
      logger.log(Rules.orgDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final appProjectPath = p.join(
      directoryService.currentPath,
      'apps',
      appProjectName,
    );
    if (await directoryService.exists(appProjectPath)) {
      logger.error('App "$appProjectName" already exists at $appProjectPath');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final appName = (argResults?['name'] as String?) ?? appProjectName;
    final orgName = (argResults?['org-name'] as String?) ?? org.split('.').last;

    final app = AppParam(
      projectName: appProjectName,
      projectPath: appProjectPath,
      org: org,
      appName: appName,
      orgName: orgName,
    );

    final progress = logger.progress(
      'Generating app "$appProjectName" with org "$org"...',
    );

    try {
      await _appService.generateApp(
        app: app,
        onProgress: (msg) => progress.update(msg),
      );
      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'App Generation Summary',
      );

      progress.complete(
        'App "$appProjectName" successfully generated under apps/$appProjectName!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate app $appProjectName: $e');
      return errorSystem;
    }
  }
}
