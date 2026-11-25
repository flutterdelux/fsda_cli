import 'package:path/path.dart' as p;

import '../../domain/params/ds_param.dart';
import 'feature_param_x.dart';

extension DsParamX on DsParam {
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
