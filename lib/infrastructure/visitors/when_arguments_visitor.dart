import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class WhenArgumentsVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  WhenArgumentsVisitor(this.onFound);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'when') {
      final closingParen = node.argumentList.rightParenthesis.offset;
      onFound(closingParen);
    }
    super.visitMethodInvocation(node);
  }
}
