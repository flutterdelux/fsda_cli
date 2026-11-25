import 'package:path/path.dart' as p;

import '../../domain/params/logic_flow_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_param_x.dart';
import 'slice_param_x.dart';
import 'state_control_x.dart';

extension LogicFlowParamX on LogicFlowParam {
  String get controllerSnake =>
      '${featureSnake}_${sliceSnake}_${control.suffix}';
  String get controllerCamel => controllerSnake.camelCase;
  String get controllerPascal => controllerSnake.pascalCase;
  String get controllerPath => p.join(logicSlicePath, '$controllerSnake.dart');

  String get stateSnake => '${featureSnake}_${sliceSnake}_state';
  String get statePascal => '$featurePascal${slicePascal}State';
  String get statePath => p.join(logicSlicePath, '$stateSnake.dart');

  String get ucPath => p.join(featurePath, 'domain', 'usecases', '$uc.dart');
}
