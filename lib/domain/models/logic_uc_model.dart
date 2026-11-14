import '../enums/uc_type.dart';

class LogicUcModel {
  final String name;
  final String path;
  final UcType type;

  /// Method from UseCAse VST already in camel case format
  final String method;
  final String?
  returnType; // include List if exist e.g List<entity> also include ? if exists
  final String? paramType;

  const LogicUcModel({
    required this.name,
    required this.path,
    required this.type,
    required this.method,
    this.returnType,
    this.paramType,
  });
}
