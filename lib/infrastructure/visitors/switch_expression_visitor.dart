import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class SwitchExpressionVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  SwitchExpressionVisitor(this.onFound);

  @override
  void visitSwitchExpression(SwitchExpression node) {
    if (node.expression.toSource().contains('this')) {
      for (final expCase in node.cases) {
        if (expCase.guardedPattern.toSource().contains('_')) {
          onFound(expCase.offset);
          break;
        }
      }
    }
    super.visitSwitchExpression(node);
  }
}
