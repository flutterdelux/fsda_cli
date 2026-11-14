import '../../domain/params/ui/ui_gate_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension UiGateParamX on UiGateParam {
  String get modelSnake => model;
  String get modelCamel => modelSnake.camelCase;
  String get modelPascal => modelSnake.pascalCase;
  String get modelTitle => modelSnake.titleCase;
}
