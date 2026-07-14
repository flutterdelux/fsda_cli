import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class DiVisitor extends RecursiveAstVisitor<void> {
  Block? initDiBlock;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.name.lexeme == 'initDI') {
      final body = node.functionExpression.body;
      if (body is BlockFunctionBody) {
        initDiBlock = body.block;
      }
    }
    super.visitFunctionDeclaration(node);
  }
}
