import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

class WorkspaceService {
  bool get isInsideWorkspace {
    final currentDir = Directory.current;
    final markerFile = File(p.join(currentDir.path, 'fsda.yaml'));

    return markerFile.existsSync();
  }

  void ensureInsideWorkspace(String usage) {
    if (!isInsideWorkspace) {
      throw UsageException(
        'Not inside a fsda workspace. Please navigate to a valid workspace directory.',
        usage,
      );
    }
  }
}
