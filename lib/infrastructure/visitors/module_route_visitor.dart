import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'callback_ast_visitor.dart';

class ModuleRouteVisitor extends RecursiveAstVisitor<void> {
  final String routeClassName;
  final String featureBaseGetterName;

  int? classBodyOffset;
  int? classEndOffset;
  int? routesInsertOffset;
  bool routesIsEmpty = true;

  ModuleRouteVisitor({
    required this.routeClassName,
    required this.featureBaseGetterName,
  });

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.namePart.typeName.lexeme != routeClassName) {
      return;
    }

    final body = node.body;
    if (body is BlockClassBody) {
      classBodyOffset = body.leftBracket.end;
      classEndOffset = body.rightBracket.offset;
    }

    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isGetter && node.name.lexeme == featureBaseGetterName) {
      final routesList = _findRoutesListLiteral(node.body);
      if (routesList != null) {
        routesIsEmpty = routesList.elements.isEmpty;
        routesInsertOffset = routesIsEmpty
            ? routesList.leftBracket.end
            : routesList.elements.last.end;
      }
    }

    super.visitMethodDeclaration(node);
  }

  ListLiteral? _findRoutesListLiteral(FunctionBody body) {
    ListLiteral? found;

    void visitNode(AstNode? node) {
      if (node == null || found != null) return;
      if (node is NamedExpression &&
          node.name.label.name == 'routes' &&
          node.expression is ListLiteral) {
        found = node.expression as ListLiteral;
        return;
      }
      node.visitChildren(CallbackAstVisitor(visitNode));
    }

    visitNode(body);
    return found;
  }
}
