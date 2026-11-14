import 'package:path/path.dart' as p;

import '../../domain/params/inputs/input_gate_param.dart';

extension InputGateParamX on InputGateParam {
  String get widgetPath => p.join(
    featurePath,
    'ui',
    'shared',
    'widgets',
    '${featureName}_${field}_field.dart',
  );
}
