import 'dart:io';

import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:test/test.dart';

void main() {
  late DirectoryService directoryService;
  late Directory tempDir;

  setUp(() async {
    directoryService = DirectoryService();
    // Membuat direktori sementara untuk setiap tes
    tempDir = await Directory.systemTemp.createTemp('fsda_test_');
  });

  tearDown(() async {
    // Membersihkan direktori sementara setelah tes selesai
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DirectoryService Tests', () {
    test('currentPath should return a valid string path', () {
      final path = directoryService.currentPath;
      expect(path, isNotEmpty);
      expect(path, Directory.current.path); //
    });

    test(
      'exists should return true if directory exists and false otherwise',
      () async {
        final subDirPath = '${tempDir.path}/sub_dir';

        // Belum dibuat, harus false
        expect(await directoryService.exists(subDirPath), isFalse);

        // Buat direktori
        await Directory(subDirPath).create();

        // Sudah dibuat, harus true
        expect(await directoryService.exists(subDirPath), isTrue); //
      },
    );

    test('dirOf should return Directory instance with correct path', () {
      final dir = directoryService.dirOf(tempDir.path);
      expect(dir, isA<Directory>());
      expect(dir.path, tempDir.path);
    });

    test('create should create directory successfully', () async {
      final newDirPath = '${tempDir.path}/new_folder/nested';
      await directoryService.create(newDirPath);

      expect(await directoryService.exists(newDirPath), isTrue);
    });

    test('delete should remove directory successfully', () async {
      final targetPath = '${tempDir.path}/to_delete';
      await Directory(targetPath).create();
      expect(await Directory(targetPath).exists(), isTrue);

      await directoryService.delete(targetPath);
      expect(await Directory(targetPath).exists(), isFalse);
    });

    test(
      'listSync should return empty list if directory does not exist',
      () async {
        final nonExistentPath = '${tempDir.path}/non_existent';
        final result = await directoryService.listSync(nonExistentPath);

        expect(result, isEmpty);
      },
    );

    test(
      'listSync should return list of FileSystemEntity when directory exists',
      () async {
        await File('${tempDir.path}/file1.txt').create();
        await Directory('${tempDir.path}/dir1').create();

        final result = await directoryService.listSync(tempDir.path);
        expect(result.length, 2);
      },
    );

    test(
      'listFilePaths should filter and return file paths correctly based on where callback',
      () async {
        final filePath = '${tempDir.path}/test_file.arb';
        final txtPath = '${tempDir.path}/test_file.txt';
        await File(filePath).create();
        await File(txtPath).create();

        final filePaths = await directoryService.listPaths(
          dirPath: tempDir.path,
          where: (fileSystem, isFile) =>
              isFile && fileSystem.path.endsWith('.arb'),
        );

        expect(filePaths.length, 1);
        expect(filePaths.first, contains('test_file.arb'));
      },
    );

    test(
      'listFilePaths should return empty list if dirPath does not exist',
      () async {
        final result = await directoryService.listPaths(
          dirPath: '${tempDir.path}/invalid_path',
          where: (_, _) => true,
        );

        expect(result, isEmpty);
      },
    );
  });
}
