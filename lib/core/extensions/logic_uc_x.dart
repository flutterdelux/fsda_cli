import '../../domain/models/logic_uc_model.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension LogicUcX on LogicUcModel {
  String get ucSnake => name;
  String get ucCamel => ucSnake.camelCase;
  String get ucPascal => ucSnake.pascalCase;

  String? get returnSnake => returnType;
  String? get returnCamel => returnSnake?.camelCase;
  String? get returnPascal => returnSnake?.pascalCase;

  String? get paramSnake => paramType;
  String? get paramCamel => paramSnake?.camelCase;
  String? get paramPascal => paramSnake?.pascalCase;
}
