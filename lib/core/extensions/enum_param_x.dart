import 'package:path/path.dart' as p;

import '../../domain/params/enum_param.dart';

extension EnumParamX on EnumParam {
  String get featureBarrelPath =>
      p.join(featurePath, '${featureName}_feature.dart');
}
