import 'package:path/path.dart' as p;

import '../../domain/params/feature_gate_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension FeatureGateParamX on FeatureGateParam {
  String get featureSnake => featureName;
  String get featureCamel => featureSnake.camelCase;
  String get featurePascal => featureSnake.pascalCase;
  String get featureTitle => featureSnake.titleCase;

  String get featureBarrelPath =>
      p.join(featurePath, '${featureSnake}_feature.dart');
}
