import 'package:path/path.dart' as p;

import '../../domain/params/ds_param.dart';

extension DsParamX on DsParam {
  String get featureBarrelPath =>
      p.join(featurePath, '${featureName}_feature.dart');

  String get interfacePath => p.join(
    featurePath,
    'data',
    'datasources',
    '${featureName}_${mode.value}_data_source.dart',
  );

  String get implPath => p.join(
    featurePath,
    'data',
    'datasources',
    '${featureName}_${mode.value}_data_source_impl.dart',
  );
}
