import 'package:path/path.dart' as p;

import '../../domain/params/feature_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'module_param_x.dart';

extension FeatureParamX on FeatureParam {
  String get featureSnake => featureName;
  String get featureCamel => featureSnake.camelCase;
  String get featurePascal => featureSnake.pascalCase;
  String get featureTitle => featureSnake.titleCase;

  String get featurePath =>
      p.join(modulePath, 'lib', 'src', 'features', featureSnake);

  String get featureBarrelPath =>
      p.join(featurePath, '${featureSnake}_feature.dart');

  String get repoInterfacePath => p.join(
    featurePath,
    'domain',
    'repositories',
    '${featureSnake}_repository.dart',
  );

  String get repoImplPath => p.join(
    featurePath,
    'data',
    'repositories',
    '${featureSnake}_repository_impl.dart',
  );
}
