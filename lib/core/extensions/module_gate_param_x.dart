import '../../domain/params/module_gate_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension ModuleGateParamX on ModuleGateParam {
  String get moduleSnake => moduleName;
  String get moduleCamel => moduleSnake.camelCase;
  String get modulePascal => moduleSnake.pascalCase;
}
