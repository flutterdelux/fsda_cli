import 'dart:io';

class ProcessService {
  Future<void> run(
    String executable,
    List<String> arguments,
    String workingDirPath,
  ) async {
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirPath,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception(
        'Failed to execute command: $executable ${arguments.join(' ')}\n${result.stderr}',
      );
    }
  }
}
