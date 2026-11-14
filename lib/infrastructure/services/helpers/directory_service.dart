import 'dart:io';

class DirectoryService {
  String get currentPath => Directory.current.path;

  Future<bool> exists(String path) async {
    return await Directory(path).exists();
  }

  Directory dirOf(String path) => Directory(path);

  Future<void> create(String path, {bool recursive = true}) async {
    await Directory(path).create(recursive: recursive);
  }

  Future<void> delete(String path, {bool recursive = true}) async {
    await Directory(path).delete(recursive: recursive);
  }

  Future<List<FileSystemEntity>> listSync(
    String path, {
    bool recursive = false,
  }) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];
    return dir.listSync(recursive: recursive);
  }

  Future<List<String>> listFilePaths({
    required String dirPath,
    required bool Function(FileSystemEntity fileSystem, bool isFile) where,
  }) async {
    final dir = Directory(dirPath);
    if (!await exists(dirPath)) return [];
    return dir
        .listSync()
        .where((e) => where(e, e is File))
        .map((e) => e.path)
        .toList();
  }
}
