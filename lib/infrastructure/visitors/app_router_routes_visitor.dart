import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class AppRouterRoutesVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  AppRouterRoutesVisitor(this.onFound);

  @override
  void visitNamedExpression(NamedExpression node) {
    // Cari parameter 'routes:' secara langsung di mana saja dalam file router
    if (node.name.label.name == 'routes') {
      if (node.expression is ListLiteral) {
        final listLiteral = node.expression as ListLiteral;
        // Ambil offset sebelum kurung siku tutup ']' agar aman
        onFound(listLiteral.rightBracket.offset);
        return;
      }
    }
    super.visitNamedExpression(node);
  }
}
