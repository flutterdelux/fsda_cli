import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../domain/models/dependency_metadata.dart';

class LogicVisitor extends RecursiveAstVisitor<void> {
  String? className;
  String? extendsClass;
  String? method;
  final List<DependencyParamMetadata> parameters = [];
  final List<DependencyParamMetadata> methodParameters = [];

  final Map<String, String> _fieldTypes = {};

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    className = node.namePart.typeName.lexeme;

    extendsClass = node.extendsClause?.superclass.name.lexeme;

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
  void visitMethodDeclaration(MethodDeclaration node) {
    final methodName = node.name.lexeme;

    if (method == null &&
        !node.isGetter &&
        !methodName.startsWith('_') &&
        methodName != 'build') {
      method = methodName;
      methodParameters.addAll(_extractFormalParams(node.parameters));
    }

    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.name == null || node.name?.lexeme == '') {
      parameters.addAll(
        _extractFormalParams(node.parameters, excludeNames: const {'key'}),
      );
    }
    super.visitConstructorDeclaration(node);
  }

  List<DependencyParamMetadata> _extractFormalParams(
    FormalParameterList? paramList, {
    Set<String> excludeNames = const {},
  }) {
    if (paramList == null) return const [];
    final result = <DependencyParamMetadata>[];

    for (final formalParam in paramList.parameters) {
      String? defaultValue;
      FormalParameter param = formalParam;

      if (formalParam is DefaultFormalParameter) {
        defaultValue = formalParam.defaultValue?.toSource();
        param = formalParam.parameter;
      }

      String name = '';
      String type = 'dynamic';
      final bool isNamed = formalParam.isNamed;

      if (param is FieldFormalParameter) {
        name = param.name.lexeme;
        type = param.type?.toSource() ?? _fieldTypes[name] ?? 'dynamic';
      } else if (param is SuperFormalParameter) {
        name = param.name.lexeme;
        type = param.type?.toSource() ?? 'dynamic';
      } else if (param is SimpleFormalParameter) {
        name = param.name?.lexeme ?? '';
        type = param.type?.toSource() ?? 'dynamic';
      }

      if (excludeNames.contains(name)) continue;

      if (name.isNotEmpty) {
        result.add(
          DependencyParamMetadata(
            name: name,
            type: type,
            isNamed: isNamed,
            defaultValue: defaultValue,
          ),
        );
      }
    }

    return result;
  }
}
