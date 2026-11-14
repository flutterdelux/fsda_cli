import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class SwitchStatementVisitor extends RecursiveAstVisitor<void> {
  final void Function(int insertOffset) onFound;

  SwitchStatementVisitor(this.onFound);

  @override
  void visitSwitchExpression(SwitchExpression node) {
    if (node.expression.toSource().contains('code')) {
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
