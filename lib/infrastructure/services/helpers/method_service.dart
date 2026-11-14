import 'package:analyzer/dart/analysis/utilities.dart';

import '../../text_modifiers/string_extension.dart';
import '../../visitors/class_body_visitor.dart';
import '../../visitors/method_visitor.dart';
import 'file_service.dart';

class MethodService {
  final FileService _fileService;

  const MethodService({required FileService fileService})
    : _fileService = fileService;

  Future<bool> hasMethod({
    required String path,
    required String methodName,
  }) async {
    if (!await _fileService.exists(path)) return false;

    final content = await _fileService.readAsString(path);
    final parseResult = parseString(
      content: content,
      throwIfDiagnostics: false,
    );
    final unit = parseResult.unit;

    bool methodExists = false;
    final camelMethodName = methodName.camelCase;

    unit.accept(
      MethodVisitor(
        targetMethodName: camelMethodName,
        onMethodFound: (_) {
          methodExists = true;
        },
      ),
    );

    return methodExists;
  }

  Future<void> injectToClass({
    required String path,
    required String methodCode,
  }) async {
    if (!await _fileService.exists(path)) return;

    final content = await _fileService.readAsString(path);
    final parseResult = parseString(
      content: content,
      throwIfDiagnostics: false,
    );
    final unit = parseResult.unit;

    int? insertOffset;
    unit.accept(
      ClassBodyVisitor(
        onClassFound: (classDecl) {
          insertOffset = classDecl.endToken.offset;
        },
      ),
    );

    if (insertOffset == null) return;

    final updatedContent =
        '${content.substring(0, insertOffset)}\n$methodCode\n${content.substring(insertOffset!)}';

    await _fileService.writeAsString(path: path, content: updatedContent);
  }

  /// [methodName] accept snake case format
  Future<void> unjectFromClass({
    required String path,

    required String methodName,
  }) async {
    if (!await _fileService.exists(path)) return;

    final content = await _fileService.readAsString(path);
    final parseResult = parseString(
      content: content,
      throwIfDiagnostics: false,
    );
    final unit = parseResult.unit;

    int? startOffset;
    int? endOffset;

    unit.accept(
      MethodVisitor(
        targetMethodName: methodName.camelCase,
        onMethodFound: (methodNode) {
          startOffset = methodNode.offset;
          endOffset = methodNode.end;
        },
      ),
    );

    if (startOffset == null || endOffset == null) return;

    // Bersihkan juga sisa baris kosong jika ada
    final updatedContent =
        '${content.replaceRange(startOffset!, endOffset!, '').trim()}\n';

    await _fileService.writeAsString(path: path, content: updatedContent);
  }
}
