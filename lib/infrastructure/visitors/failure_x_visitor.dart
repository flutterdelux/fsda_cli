import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class FailureXVisitor extends RecursiveAstVisitor<void> {
  final void Function(int offset) onFound;

  FailureXVisitor(this.onFound);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme == 'localizeAny') {
      final body = node.body;
      if (body is BlockFunctionBody) {
        // Cari pernyataan return paling akhir (misal `return l10n.unknownError;`)
        for (final statement in body.block.statements) {
          if (statement is ReturnStatement) {
            onFound(statement.offset);
            return;
          }
        }
        onFound(body.block.rightBracket.offset);
      }
    }
    super.visitMethodDeclaration(node);
  }
}
