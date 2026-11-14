import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class LocalizationsDelegatesVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  LocalizationsDelegatesVisitor(this.onFound);

  @override
  void visitNamedExpression(NamedExpression node) {
    if (node.name.label.name == 'localizationsDelegates') {
      if (node.expression is ListLiteral) {
        final listLiteral = node.expression as ListLiteral;
        if (listLiteral.elements.isNotEmpty) {
          // Ambil end dari elemen terakhir
          onFound(listLiteral.elements.last.end);
        } else {
          // Jika list kosong, masukkan di dalam kurung siku
          onFound(listLiteral.leftBracket.end);
        }
      }
    }
    super.visitNamedExpression(node);
  }
}
