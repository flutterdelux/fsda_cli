import 'package:path/path.dart' as p;

import '../../domain/params/app_integration/reg_module_param.dart';
import 'app_param_x.dart';
import 'module_param_x.dart';

extension RegModuleParamX on RegModuleParam {
  /// For module dependency registration
  String get appPubspecPath => p.join(appPath, 'pubspec.yaml');

  /// For module structure creation
  String get appModulePath => p.join(appPath, 'lib', 'modules', moduleSnake);
  String get appModuleDiPath => p.join(appModulePath, '${moduleSnake}_di.dart');
  String get appModuleRoutePath =>
      p.join(appModulePath, '${moduleSnake}_route.dart');

  /// For module injection parts
  /// Localization, Failure, DI, Router
  String get mainAppPath => p.join(appPath, 'lib', 'app', 'main_app.dart');
  String get failureXPath =>
      p.join(appPath, 'lib', 'core', 'extensions', 'failure_x.dart');
  String get appDiPath => p.join(appPath, 'lib', 'core', 'di', 'di.dart');
  String get appRouterPath => p.join(appPath, 'lib', 'app', 'app_router.dart');
}
