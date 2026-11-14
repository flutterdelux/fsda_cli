import 'package:path/path.dart' as p;

import '../../domain/params/failure_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension FailureParamX on FailureParam {
  String get exceptionPath => p.join(
    modulePath,
    'lib',
    'src',
    'shared',
    'data',
    'errors',
    '${moduleName}_exception.dart',
  );
  String get failurePath => p.join(
    modulePath,
    'lib',
    'src',
    'shared',
    'domain',
    'errors',
    '${moduleName}_failure.dart',
  );
  String get extensionPath => p.join(
    modulePath,
    'lib',
    'src',
    'shared',
    'ui',
    'extensions',
    '${moduleName}_failure_x.dart',
  );

  String get nameSnake => name;
  String get nameCamel => nameSnake.camelCase;
  String get namePascal => nameSnake.pascalCase;
  String get nameCode => nameSnake.toUpperCase();
}
