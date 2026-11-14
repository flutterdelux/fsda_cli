import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../domain/models/prop_model.dart';

class ModelVisitor extends RecursiveAstVisitor<void> {
  final List<PropModel> props = [];

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    super.visitConstructorDeclaration(node);

    // Menangkap parameter dari constructor utama/factory Freezed
    if (node.parameters.parameters.isEmpty) return;

    for (final param in node.parameters.parameters) {
      FormalParameter actualParam = param;
      String type = '';
      String defaultValue = '';

      if (param is DefaultFormalParameter) {
        actualParam = param.parameter;
        if (param.defaultValue != null) {
          defaultValue = param.defaultValue!.toSource();
        }
      }

      if (actualParam is SimpleFormalParameter) {
        type = actualParam.type?.toSource() ?? 'dynamic';
      } else if (actualParam is FieldFormalParameter) {
        type = actualParam.type?.toSource() ?? '';
      }

      final identifier = actualParam.name;
      if (identifier != null) {
        final snakeCaseName = _toSnakeCase(identifier.lexeme);

        props.add(
          PropModel(
            type: type,
            name: snakeCaseName,
            defaultValue: defaultValue,
            converter: '',
          ),
        );
      }
    }
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => '_${m.group(0)}',
        )
        .toLowerCase();
  }
}
