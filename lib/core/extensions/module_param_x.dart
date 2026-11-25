import 'package:path/path.dart' as p;

import '../../domain/params/module_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension ModuleParamX on ModuleParam {
  String get moduleSnake => moduleName;
  String get moduleCamel => moduleSnake.camelCase;
  String get modulePascal => moduleSnake.pascalCase;

  String get modulePath => p.join(workspacePath, 'modules', moduleSnake);
  String get moduleBarrelPath =>
      p.join(workspacePath, 'modules', moduleSnake, 'lib', '$moduleSnake.dart');
}
