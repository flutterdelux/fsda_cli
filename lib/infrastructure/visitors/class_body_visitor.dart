import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// AST Visitor untuk mendeteksi deklarasi kelas dan posisi kurung kurawal penutupnya
class ClassBodyVisitor extends RecursiveAstVisitor<void> {
  final void Function(ClassDeclaration) onClassFound;

  ClassBodyVisitor({required this.onClassFound});

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);
    onClassFound(node);
  }
}
