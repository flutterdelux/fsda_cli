import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class MainAppVisitor extends RecursiveAstVisitor<void> {
  ListLiteral? delegatesList;

  @override
  void visitNamedExpression(NamedExpression node) {
    if (node.name.label.name == 'localizationsDelegates') {
      final expression = node.expression;
      if (expression is ListLiteral) {
        delegatesList = expression;
      }
    }
    super.visitNamedExpression(node);
  }
}
