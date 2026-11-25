import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;

import '../../../domain/models/logic_uc_model.dart';
import '../../text_modifiers/string_extension.dart';
import '../../visitors/use_case_visitor.dart';
import 'file_service.dart';

class LogicUcService {
  final FileService _fileService;

  const LogicUcService({required FileService fileService})
    : _fileService = fileService;

  Future<LogicUcModel> inspectUseCase(String usecasePath) async {
    if (!await _fileService.exists(usecasePath)) {
      throw Exception('Use case file not found at $usecasePath');
    }

    final content = await _fileService.readAsString(usecasePath);
    final parseResult = parseString(
      content: content,
      throwIfDiagnostics: false,
    );
    final unit = parseResult.unit;

    final visitor = UseCaseVisitor();
    unit.accept(visitor);

    if (visitor.detectedUcType == null) {
      throw Exception(
        'Failed to detect UcType in $usecasePath. Make sure the class extends a valid UseCase interface.',
      );
    }

    return LogicUcModel(
      name:
          visitor.className?.snakeCase ??
          p.basenameWithoutExtension(usecasePath),
      path: usecasePath,
      type: visitor.detectedUcType!,
      repoMethod: visitor.detectedMethod ?? 'call',
      returnType: visitor.returnType,
      paramType: visitor.paramType,
    );
  }
}
