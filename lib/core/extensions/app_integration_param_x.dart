import 'package:path/path.dart' as p;

import '../../domain/params/app_integration/app_integration_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension AppIntegrationParamX on AppIntegrationParam {
  String get moduleSnake => moduleName;
  String get moduleCamel => moduleName.camelCase;
  String get modulePascal => moduleName.pascalCase;

  String? get featureSnake => featureName;
  String? get featureCamel => featureName?.camelCase;
  String? get featurePascal => featureName?.pascalCase;

  String get appModulePath => p.join(appPath, 'lib', 'modules', moduleSnake);

  String get appModuleDiPath => p.join(appModulePath, '${moduleSnake}_di.dart');

  String get appModuleRoutePath =>
      p.join(appModulePath, '${moduleSnake}_route.dart');

  String get mainAppPath => p.join(appPath, 'lib', 'app', 'main_app.dart');
  String get failureXPath =>
      p.join(appPath, 'lib', 'core', 'extensions', 'failure_x.dart');
  String get appDiPath => p.join(appPath, 'lib', 'core', 'di', 'di.dart');
  String get appRouterPath => p.join(appPath, 'lib', 'app', 'app_router.dart');

  String get appPubspecPath => p.join(appPath, 'pubspec.yaml');
}
