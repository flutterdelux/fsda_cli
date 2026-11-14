import 'package:path/path.dart' as p;

import '../../domain/params/logic_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_gate_param_x.dart';
import 'slice_gate_param_x.dart';
import 'state_control_x.dart';

extension LogicParamX on LogicParam {
  String get controllerSnake =>
      '${featureSnake}_${sliceSnake}_${control.suffix}';
  String get controllerCamel => controllerSnake.camelCase;
  String get controllerPascal => controllerSnake.pascalCase;
  String get controllerPath =>
      p.join(featurePath, 'logic', sliceSnake, '$controllerSnake.dart');

  String get stateSnake => '${featureSnake}_${sliceSnake}_state';
  String get statePascal => '$featurePascal${slicePascal}State';
  String get statePath =>
      p.join(featurePath, 'logic', sliceSnake, '$stateSnake.dart');
}
