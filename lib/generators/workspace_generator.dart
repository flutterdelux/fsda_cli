import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/cli_info.dart';
import '../constants/cli_messages.dart';
import '../generated/package_bundle.dart';
import 'base_generator.dart';

class WorkspaceGenerator extends BaseGenerator<void, String> {
  WorkspaceGenerator({required super.logger});

  @override
  Future<void> generate(String name) async {
    final root = Directory(p.join(Directory.current.path, name));

    if (await root.exists()) {
      logger.error('Workspace "$name" already exists');
      return;
    }

    for (final dir in ['apps', 'modules', 'packages']) {
      await Directory(p.join(root.path, dir)).create(recursive: true);
    }

    final packages = packageBundle.keys.toList()..sort();

    await File(p.join(root.path, 'fsda.yaml')).writeAsString(
      CliInfo.getConfigYaml(workspaceName: name, packages: packages),
    );

    logger.success('Workspace "$name" created successfully');

    logger.log(CliMessages.workspaceCreatedNextSteps(name));
  }
}
