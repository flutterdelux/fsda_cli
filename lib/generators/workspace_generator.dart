import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/cli_info.dart';
import '../constants/cli_messages.dart';
import '../generated/package_bundle.dart';
import '../services/operation_report_service.dart';
import 'base_generator.dart';

class WorkspaceGenerator extends BaseGenerator<void, String> {
  WorkspaceGenerator({required super.logger});

  @override
  Future<void> generate(String name) async {
    final root = Directory(p.join(Directory.current.path, name));
    final report = OperationReportService();

    if (await root.exists()) {
      logger.error('Workspace "$name" already exists');
      return;
    }

    for (final dir in ['apps', 'modules', 'packages']) {
      final dirPath = p.join(root.path, dir);
      await Directory(dirPath).create(recursive: true);
      report.addCreated(dirPath);
    }

    final packages = packageBundle.keys.toList()..sort();

    final configPath = p.join(root.path, 'fsda.yaml');
    await File(configPath).writeAsString(
      CliInfo.getConfigYaml(workspaceName: name, packages: packages),
    );
    report.addCreated(configPath);

    logger.success('Workspace "$name" created successfully');
    report.logSummary(logger, operationLabel: 'fsda create');

    logger.log(CliMessages.workspaceCreatedNextSteps(name));
  }
}
