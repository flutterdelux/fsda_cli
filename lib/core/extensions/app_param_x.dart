import 'package:path/path.dart' as p;

import '../../domain/params/app_param.dart';

extension AppParamX on AppParam {
  String get appPath => p.join(workspacePath, 'apps', appName);
}
