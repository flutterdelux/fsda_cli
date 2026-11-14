import 'dart:io';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:test/test.dart';

void main() {
  late ProcessService processService;
  late Directory tempDir;

  setUp(() async {
    processService = ProcessService();
    tempDir = await Directory.systemTemp.createTemp('process_service_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ProcessService Tests', () {
    test('run should execute command successfully when exitCode is 0', () async {
      // Menggunakan perintah umum seperti 'dart' dengan argumen '--version' yang pasti ada di lingkungan Flutter/Dart SDK
      // Atau perintah 'echo' / 'true' tergantung OS, namun 'dart' sangat aman untuk CLI project.
      final executable = Platform.isWindows ? 'dart.bat' : 'dart';

      // Memastikan pemanggilan proses berjalan sukses tanpa melempar Exception
      expect(
        () async =>
            await processService.run(executable, ['--version'], tempDir.path),
        returnsNormally,
      );
    });

    test('run should throw Exception when exitCode is non-zero', () async {
      // Menjalankan perintah yang tidak valid untuk memicu exitCode != 0 dan error output
      final invalidExecutable = 'invalid_executable_command_xyz';

      expect(
        () async =>
            await processService.run(invalidExecutable, [], tempDir.path),
        throwsException,
      );
    });
  });
}
