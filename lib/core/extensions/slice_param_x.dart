import 'package:path/path.dart' as p;

import '../../domain/params/slice_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_param_x.dart';

extension SliceParamX on SliceParam {
  String get sliceSnake => sliceName;
  String get sliceCamel => sliceSnake.camelCase;
  String get slicePascal => sliceSnake.pascalCase;
  String get sliceTitle => sliceSnake.titleCase;

  String get logicSlicePath => p.join(featurePath, 'logic', sliceSnake);
  String get uiSlicePath => p.join(featurePath, 'ui', sliceSnake);
}
