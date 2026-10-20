import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/cli_info.dart';
import '../generated/package_bundle.dart';
import '../services/logger_service.dart';
import '../services/operation_report_service.dart';

class WorkspaceGenerator {
  final LoggerService logger;
  final OperationReportService report;

  WorkspaceGenerator({required this.logger, required this.report});

  Future<void> generate({required String name}) async {
    final root = Directory(p.join(Directory.current.path, name));

    if (await root.exists()) {
      logger.error('Workspace "$name" already exists');
      return;
    }

    for (final dir in ['apps', 'modules', 'packages']) {
      try {
        final dirPath = p.join(root.path, dir);
        await Directory(dirPath).create(recursive: true);
        report.addCreated(dirPath);
      } catch (e) {
        logger.error(
          'Failed to create diretory "$dir" in workspace "$name": $e',
        );
      }
    }

    final packages = packageBundle.keys.toList()..sort();

    final configPath = p.join(root.path, 'fsda.yaml');
    await File(configPath).writeAsString(
      CliInfo.getConfigYaml(workspaceName: name, packages: packages),
    );
    report.addCreated(configPath);

    report.logSummary(logger, operationLabel: 'fsda create $name');

    logger.success('Workspace "$name" created successfully.');
  }
}
