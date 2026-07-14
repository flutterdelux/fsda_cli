import 'package:mason/mason.dart';

class MemoryGeneratorTarget implements GeneratorTarget {
  final files = <String, List<int>>{};

  @override
  Future<GeneratedFile> createFile(
    String path,
    List<int> contents, {
    Logger? logger,
    OverwriteRule? overwriteRule,
  }) async {
    files[path] = contents;
    return GeneratedFile.created(path: path);
  }
}
