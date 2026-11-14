import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../domain/enums/uc_type.dart';

class UseCaseVisitor extends RecursiveAstVisitor<void> {
  UcType? detectedUcType;
  String? detectedMethod;
  String? returnType;
  String? paramType;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final extendsClause = node.extendsClause;
    if (extendsClause == null) return;

    final superType = extendsClause.superclass;
    final superTypeName = superType.name.lexeme;

    // Deteksi UcType dari superclass
    detectedUcType = UcType.fromValue(superTypeName);

    // Ekstrak Type Arguments jika ada (misal: ReturnParamUseCase<List<TaskEntity>, TaskParam>)
    final typeArgs = superType.typeArguments?.arguments;
    if (typeArgs != null && typeArgs.isNotEmpty) {
      if (typeArgs.length == 1) {
        // Single generic type (e.g., ReturnUseCase<T> atau ParamUseCase<P>)
        if (superTypeName.contains('Param')) {
          paramType = typeArgs[0].toSource();
        } else {
          returnType = typeArgs[0].toSource();
        }
      } else if (typeArgs.length >= 2) {
        // Dual generic types (e.g., ReturnParamUseCase<T, P>)
        returnType = typeArgs[0].toSource();
        paramType = typeArgs[1].toSource();
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    // Cari panggilan method ke _repository.<methodName>(...)
    final target = node.target;
    if (target is SimpleIdentifier && target.name == '_repository') {
      detectedMethod = node.methodName.name;
    }
  }
}
