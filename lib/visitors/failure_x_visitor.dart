import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class FailureXVisitor extends RecursiveAstVisitor<void> {
  ReturnStatement? targetReturnStatement;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme == 'localizeAny') {
      super.visitMethodDeclaration(node);
    }
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    if (node.toSource().contains('unknownError')) {
      targetReturnStatement = node;
    }
    super.visitReturnStatement(node);
  }
}
