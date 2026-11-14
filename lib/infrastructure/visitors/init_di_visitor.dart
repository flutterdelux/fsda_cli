import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class InitDiVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  InitDiVisitor(this.onFound);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.name.lexeme == 'initDI') {
      final body = node.functionExpression.body;
      if (body is BlockFunctionBody) {
        onFound(body.block.rightBracket.offset);
      }
    }
    super.visitFunctionDeclaration(node);
  }
}
