import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../enums/di_class_type.dart';
import '../models/di_class_info.dart';
import '../models/di_param.dart';

class DiAstVisitor extends RecursiveAstVisitor<void> {
  final List<DiClassInfo> classes = [];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.abstractKeyword != null) {
      super.visitClassDeclaration(node);
      return;
    }

    final className = node.namePart.typeName.lexeme;
    final type = DiClassType.fromValue(className);

    if (type == null) {
      super.visitClassDeclaration(node);
      return;
    }

    String? interfaceName;
    if (node.implementsClause != null &&
        node.implementsClause!.interfaces.isNotEmpty) {
      interfaceName = node.implementsClause!.interfaces.first.name.lexeme;
    } else if (node.extendsClause != null) {
      interfaceName = node.extendsClause!.superclass.name.lexeme;
    }

    final parameters = <DiParam>[];
    for (final entity in node.childEntities) {
      if (entity is! BlockClassBody) continue;

      for (final bodyEntity in entity.childEntities) {
        if (bodyEntity is! ConstructorDeclaration) continue;
        if (bodyEntity.name != null) continue;

        for (final param in bodyEntity.parameters.parameters) {
          final paramName = param.name?.lexeme;
          if (paramName == null || paramName.isEmpty) continue;

          parameters.add(
            DiParam(
              name: paramName,
              isNamed: param.isNamed,
              typeName: _extractParameterTypeName(param),
            ),
          );
        }
      }
    }

    classes.add(
      DiClassInfo(
        className: className,
        interfaceName: interfaceName,
        parameters: parameters,
        type: type,
      ),
    );

    super.visitClassDeclaration(node);
  }

  String? _extractParameterTypeName(FormalParameter param) {
    FormalParameter baseParam = param;
    if (baseParam is DefaultFormalParameter) {
      baseParam = baseParam.parameter;
    }

    TypeAnnotation? typeAnnotation;
    if (baseParam is SimpleFormalParameter) {
      typeAnnotation = baseParam.type;
    } else if (baseParam is FieldFormalParameter) {
      typeAnnotation = baseParam.type;
    } else if (baseParam is SuperFormalParameter) {
      typeAnnotation = baseParam.type;
    }

    final rawType = typeAnnotation?.toSource();
    if (rawType == null || rawType.isEmpty) return null;

    return rawType.replaceAll('?', '');
  }
}
