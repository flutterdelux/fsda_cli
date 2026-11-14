import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class DiFunctionVisitor extends RecursiveAstVisitor<void> {
  final String targetFunctionName;
  int? insertOffset;

  DiFunctionVisitor(this.targetFunctionName);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.name.lexeme == targetFunctionName) {
      final body = node.functionExpression.body;
      if (body is BlockFunctionBody) {
        // Posisi tepat sebelum kurung tutup penutup fungsi `}`
        insertOffset = body.block.endToken.offset;
      }
    }
    super.visitFunctionDeclaration(node);
  }
}
