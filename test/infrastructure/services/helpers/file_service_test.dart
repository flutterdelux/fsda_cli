import 'dart:io';

import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:test/test.dart';

void main() {
  late FileService fileService;
  late Directory tempDir;

  setUp(() async {
    fileService = FileService();
    // Membuat direktori sementara sebelum setiap tes
    tempDir = await Directory.systemTemp.createTemp('file_service_test_');
  });

  tearDown(() async {
    // Membersihkan direktori sementara setelah tes selesai
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileService Tests', () {
    test('currentPath should return a valid string path', () {
      final path = fileService.currentPath;
      expect(path, isNotEmpty);
      expect(path, Directory.current.path);
    });

    test(
      'exists should return false if file does not exist and true if it does',
      () async {
        final filePath = '${tempDir.path}/test_exists.txt';

        // Berkas belum dibuat
        expect(await fileService.exists(filePath), isFalse);

        // Berkas dibuat
        await File(filePath).create();
        expect(await fileService.exists(filePath), isTrue);
      },
    );

    test(
      'create should create file successfully with recursive option',
      () async {
        final filePath = '${tempDir.path}/nested/dir/test_create.txt';

        final createdFile = await fileService.create(filePath, recursive: true);
        expect(await createdFile.exists(), isTrue);
      },
    );

    test('delete should remove file successfully', () async {
      final filePath = '${tempDir.path}/test_delete.txt';
      final file = File(filePath);
      await file.create();
      expect(await file.exists(), isTrue);

      await fileService.delete(filePath);
      expect(await file.exists(), isFalse);
    });

    test('readAsString should return correct content of the file', () async {
      final filePath = '${tempDir.path}/test_read.txt';
      const content = 'Hello, FileService!';
      final file = File(filePath);
      await file.writeAsString(content);

      final result = await fileService.readAsString(filePath);
      expect(result, content);
    });

    test(
      'writeAsString should write content and create parent directories if needed',
      () async {
        final filePath = '${tempDir.path}/nested/folder/test_write.txt';
        const content = 'Writing content with auto-parent creation.';

        await fileService.writeAsString(path: filePath, content: content);

        final file = File(filePath);
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), content);
      },
    );
  });
}
