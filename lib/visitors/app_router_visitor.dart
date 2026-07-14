import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class AppRouterVisitor extends RecursiveAstVisitor<void> {
  ListLiteral? routesList;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.namePart.typeName.lexeme == 'AppRouter') {
      super.visitClassDeclaration(node);
    }
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    if (node.name.label.name == 'routes') {
      final expression = node.expression;
      if (expression is ListLiteral) {
        routesList = expression;
      }
    }
    super.visitNamedExpression(node);
  }
}
