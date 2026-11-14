import '../../domain/params/slice_gate_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension SliceGateParamX on SliceGateParam {
  String get sliceSnake => slice;
  String get sliceCamel => sliceSnake.camelCase;
  String get slicePascal => sliceSnake.pascalCase;
  String get sliceTitle => sliceSnake.titleCase;
}
