import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class CallbackAstVisitor extends GeneralizingAstVisitor<void> {
  final void Function(AstNode node) onVisit;

  CallbackAstVisitor(this.onVisit);

  @override
  void visitNode(AstNode node) {
    onVisit(node);
    super.visitNode(node);
  }
}
