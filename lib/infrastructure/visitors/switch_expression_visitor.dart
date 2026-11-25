import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class SwitchExpressionVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  SwitchExpressionVisitor(this.onFound);

  @override
  void visitSwitchExpression(SwitchExpression node) {
    if (node.expression.toSource().contains('this')) {
      // 1. Jika ada wildcard '_', sisipkan sebelum '_'
      for (final expCase in node.cases) {
        if (expCase.guardedPattern.toSource().contains('_')) {
          onFound(expCase.offset);
          return;
        }
      }
      // 2. Jika exhaustive enum (tanpa '_'), sisipkan sebelum '}' penutup switch
      onFound(node.rightBracket.offset);
    }
    super.visitSwitchExpression(node);
  }
}
