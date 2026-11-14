import 'dart:io';

class FileService {
  String get currentPath => Directory.current.path;

  Future<bool> exists(String path) async {
    return await File(path).exists();
  }

  Future<File> create(String path, {bool recursive = true}) async {
    return await File(path).create(recursive: recursive);
  }

  Future<void> delete(String path, {bool recursive = true}) async {
    await File(path).delete(recursive: recursive);
  }

  Future<String> readAsString(String path) async {
    return await File(path).readAsString();
  }

  Future<void> writeAsString({
    required String path,
    required String content,
  }) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
}
