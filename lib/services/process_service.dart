import 'dart:io';

class ProcessService {
  Future<void> run({
    required String label,
    required String executable,
    required List<String> arguments,
    required String workingDirectory,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    final process =
        await Process.run(
          executable,
          arguments,
          workingDirectory: workingDirectory,
          runInShell: true, // Save run for windows compatibility
        ).timeout(
          timeout,
          onTimeout: () {
            throw Exception('"$executable" timed out');
          },
        );
    final exitCode = process.exitCode;

    if (exitCode != 0) {
      throw Exception('"$label" failed with exit code $exitCode');
    }
  }

  Future<void> runCommandString({
    required String label,
    required String commandString,
    required String workingDirectory,
  }) async {
    final process = await Process.run(
      Platform.isWindows ? 'cmd' : 'sh',
      Platform.isWindows ? ['/c', commandString] : ['-c', commandString],
      workingDirectory: workingDirectory,
    );
    if (process.exitCode != 0) {
      throw Exception('"$label" failed: ${process.stderr}');
    }
  }
}
