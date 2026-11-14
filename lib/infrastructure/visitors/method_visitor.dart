import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class MethodVisitor extends RecursiveAstVisitor<void> {
  final String targetMethodName;
  final void Function(MethodDeclaration) onMethodFound;

  MethodVisitor({required this.targetMethodName, required this.onMethodFound});

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);
    if (node.name.lexeme == targetMethodName) {
      onMethodFound(node);
    }
  }
}
