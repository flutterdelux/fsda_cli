import 'dart:convert';
import 'dart:io';

import 'sdk_service.dart';

class GenerateTemplateResult {
  final int writtenCount;
  final List<String> writtenFiles;
  final int skippedCount;
  final List<String> skippedFiles;
  final bool abortedDueToExisting;

  const GenerateTemplateResult({
    required this.writtenCount,
    required this.writtenFiles,
    required this.skippedCount,
    required this.skippedFiles,
    this.abortedDueToExisting = false,
  });
}

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

  Future<GenerateTemplateResult> generateTemplate({
    required String path,
    required Map<String, List<int>> files,
    bool overwriteExisting = false,
    bool failOnExisting = false,
  }) async {
    final targetDir = Directory(path);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    var writtenCount = 0;
    final writtenFiles = <String>[];
    final skippedFiles = <String>[];

    if (!overwriteExisting && failOnExisting) {
      for (final entry in files.entries) {
        final filePath = entry.key;
        if (filePath == 'spec.yaml') continue;

        final targetFile = File('${targetDir.path}/$filePath');
        if (await targetFile.exists()) {
          skippedFiles.add(filePath);
        }
      }

      if (skippedFiles.isNotEmpty) {
        return GenerateTemplateResult(
          writtenCount: 0,
          writtenFiles: const [],
          skippedCount: skippedFiles.length,
          skippedFiles: skippedFiles,
          abortedDueToExisting: true,
        );
      }
    }

    for (final entry in files.entries) {
      final filePath = entry.key;
      final fileBytes = entry.value;

      if (filePath == 'spec.yaml') continue;

      final targetFile = File('${targetDir.path}/$filePath');

      if (!overwriteExisting && await targetFile.exists()) {
        skippedFiles.add(filePath);
        continue;
      }

      if (filePath == 'pubspec.yaml') {
        String content = utf8.decode(fileBytes);

        content = content.replaceFirst(
          RegExp(r'environment:\r?\n\s+sdk:'),
          'environment:\n  sdk: ${sdkService.dartVersion}',
        );

        await targetFile.create(recursive: true);
        await targetFile.writeAsString(content);
        writtenCount++;
        writtenFiles.add(filePath);
        continue;
      }

      await targetFile.create(recursive: true);
      await targetFile.writeAsBytes(fileBytes);
      writtenCount++;
      writtenFiles.add(filePath);
    }

    return GenerateTemplateResult(
      writtenCount: writtenCount,
      writtenFiles: writtenFiles,
      skippedCount: skippedFiles.length,
      skippedFiles: skippedFiles,
      abortedDueToExisting: false,
    );
  }
}
