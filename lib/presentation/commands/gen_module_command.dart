import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/module_param.dart';
import '../../infrastructure/services/module_service.dart';
import 'wrapper/workspace_guard_command.dart';

class GenModuleCommand extends WorkspaceGuardCommand {
  final ModuleService _moduleService;

  GenModuleCommand({
    required ModuleService moduleService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _moduleService = moduleService;

  @override
  String get name => 'gen-module';

  @override
  String get description =>
      'Generates a new FSDA Architecture module from the built-in brick template.';

  @override
  String get invocation => 'fsda $name <name>';

  @override
  Future<int> handle() async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Module name is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid module name: "$rest".');
      logger.log(Rules.moduleDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final moduleName = rest.first;

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
    if (await directoryService.exists(modulePath)) {
      logger.error('Module "$moduleName" already exists at $modulePath');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final module = ModuleParam(name: moduleName, path: modulePath);

    final progress = logger.progress('Generating module "$moduleName"...');

    try {
      await _moduleService.generate(
        module: module,
        onProgress: (msg) => progress.update(msg),
      );

      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Module Generation Summary',
      );

      progress.complete(
        'Module "$moduleName" successfully generated and configured!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate module: $e');
      return errorSystem;
    }
  }
}
