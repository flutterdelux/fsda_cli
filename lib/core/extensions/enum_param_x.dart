import 'package:path/path.dart' as p;

import '../../domain/params/enum_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_param_x.dart';

extension EnumParamX on EnumParam {
  String get enumSnake => enumName;
  String get enumCamel => enumSnake.camelCase;
  String get enumPascal => enumSnake.pascalCase;
  String get enumTitle => enumSnake.titleCase;
  String get enumPath =>
      p.join(featurePath, 'domain', 'enums', '$enumSnake.dart');

  String get converterSnake => '${enumSnake}_converter';
  String get converterCamel => converterSnake.camelCase;
  String get converterPascal => converterSnake.pascalCase;
  String get converterPath =>
      p.join(featurePath, 'data', 'converters', '$converterSnake.dart');

  String get extensionSnake => '${enumSnake}_x';
  String get extensionCamel => extensionSnake.camelCase;
  String get extensionPascal => extensionSnake.pascalCase;
  String get extensionPath =>
      p.join(featurePath, 'ui', 'shared', 'extensions', '$extensionSnake.dart');
}
