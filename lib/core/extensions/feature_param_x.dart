import 'package:path/path.dart' as p;

import '../../domain/params/feature_param.dart';

extension FeatureParamX on FeatureParam {
  String get featureBarrelPath => p.join(path, '${name}_feature.dart');

  String get repoInterfacePath =>
      p.join(path, 'domain', 'repositories', '${name}_repository.dart');

  String get repoImplPath =>
      p.join(path, 'data', 'repositories', '${name}_repository_impl.dart');
}
