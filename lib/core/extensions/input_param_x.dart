import 'package:path/path.dart' as p;

import '../../domain/params/input_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_param_x.dart';

extension InputGateParamX on InputParam {
  String get fieldSnake => field;
  String get fieldCamel => field.camelCase;
  String get fieldPascal => field.pascalCase;

  String get widgetPath => p.join(
    featurePath,
    'ui',
    'shared',
    'widgets',
    '${featureName}_${fieldSnake}_field.dart',
  );
}
