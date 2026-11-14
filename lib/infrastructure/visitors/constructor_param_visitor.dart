import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../domain/models/dependency_metadata.dart';

class ConstructorParamVisitor extends RecursiveAstVisitor<void> {
  String? className;
  final List<DependencyParamMetadata> parameters = [];

  // Simpan peta nama field -> tipe data dari deklarasi class
  final Map<String, String> _fieldTypes = {};

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    className = node.namePart.typeName.lexeme;
    _fieldTypes.clear();

    final body = node.body;
    if (body is BlockClassBody) {
      for (final member in body.members) {
        if (member is FieldDeclaration) {
          final fieldType = member.fields.type?.toSource();
          if (fieldType != null) {
            for (final variable in member.fields.variables) {
              _fieldTypes[variable.name.lexeme] = fieldType;
            }
          }
        }
      }
    }

    super.visitClassDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.name == null || node.name?.lexeme == '') {
      for (final formalParam in node.parameters.parameters) {
        String? defaultValue;
        FormalParameter param = formalParam;

        // Perbaikan 1: Gunakan if biasa, jangan Dart Record
        if (formalParam is DefaultFormalParameter) {
          defaultValue = formalParam.defaultValue?.toSource();
          param = formalParam.parameter;
        }

        String name = '';
        String type = 'dynamic';
        final bool isNamed = formalParam.isNamed;

        if (param is FieldFormalParameter) {
          name = param.name.lexeme;
          // Perbaikan 2: Ambil dari param.type jika ditulis eksplisit,
          // jika null ambil dari _fieldTypes milik class
          type = param.type?.toSource() ?? _fieldTypes[name] ?? 'dynamic';
        } else if (param is SuperFormalParameter) {
          name = param.name.lexeme;
          type = param.type?.toSource() ?? 'dynamic';
        } else if (param is SimpleFormalParameter) {
          name = param.name?.lexeme ?? '';
          type = param.type?.toSource() ?? 'dynamic';
        }

        if (name == 'key') continue;

        if (name.isNotEmpty) {
          parameters.add(
            DependencyParamMetadata(
              name: name,
              type: type,
              isNamed: isNamed,
              defaultValue: defaultValue,
            ),
          );
        }
      }
    }
    super.visitConstructorDeclaration(node);
  }
}
