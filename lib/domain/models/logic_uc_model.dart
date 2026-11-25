import '../enums/uc_type.dart';

class LogicUcModel {
  final String name;
  final String path;
  final UcType type;

  /// Method repo from UseCase VST already in camel case format.
  final String repoMethod;
  final String?
  returnType; // include List if exist e.g List<entity> also include ? if exists
  final String? paramType;

  const LogicUcModel({
    required this.name,
    required this.path,
    required this.type,
    required this.repoMethod,
    this.returnType,
    this.paramType,
  });
}
