import 'dart:convert';
import 'dart:io';

import 'sdk_service.dart';

class FileService {
  final SdkService sdkService;

  const FileService({required this.sdkService});

  Future<void> updateFile({
    required String path,
    bool Function(String content)? cancelWhen,
    void Function(List<String> lines)? updateLines,
  }) async {
    final barrelFile = File(path);

    final content = await barrelFile.readAsString();
    if (cancelWhen != null && cancelWhen(content)) {
      throw Exception('Update canceled: condition met for file $path');
    }

    final lines = content.split('\n');

    if (updateLines != null) {
      updateLines(lines);
    }

    await barrelFile.writeAsString('${lines.join('\n')}\n');
  }

  Future<void> generateTemplate({
    required String path,
    required Map<String, List<int>> files,
  }) async {
    final targetDir = Directory(path);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    for (final entry in files.entries) {
      final filePath = entry.key;
      final fileBytes = entry.value;

      if (filePath == 'spec.yaml') continue;

      final targetFile = File('${targetDir.path}/$filePath');

      if (filePath == 'pubspec.yaml') {
        String content = utf8.decode(fileBytes);

        content = content.replaceFirst(
          RegExp(r'environment:\r?\n\s+sdk:'),
          'environment:\n  sdk: ${sdkService.dartVersion}',
        );

        await targetFile.create(recursive: true);
        await targetFile.writeAsString(content);
        continue;
      }

      await targetFile.create(recursive: true);
      await targetFile.writeAsBytes(fileBytes);
    }
  }
}
