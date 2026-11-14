import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class LastGetterVisitor extends RecursiveAstVisitor<void> {
  int? insertOffset;
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isGetter) {
      insertOffset = node.end;
    }
    super.visitMethodDeclaration(node);
  }
}
