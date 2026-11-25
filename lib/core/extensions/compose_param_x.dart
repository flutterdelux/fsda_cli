import 'package:path/path.dart' as p;

import '../../domain/enums/compose_wrapper_type.dart';
import '../../domain/params/app_integration/compose_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_param_x.dart';
import 'reg_module_param_x.dart';

extension ComposeParamX on ComposeParam {
  String get logicFlowSlicePath => p.join(featurePath, 'logic', logicFlowSlice);
  String get logicSlicePath => p.join(featurePath, 'logic', logicSlice);
  String get uiSlicePath => p.join(featurePath, 'ui', uiSlice, 'widgets');

  List<String> get targetParts => targetSnake.split('_');
  String get targetBaseName =>
      targetParts.sublist(0, targetParts.length - 1).join('_');

  String get targetSnake => target;
  String get targetPascal => targetSnake.pascalCase;
  String get targetPath =>
      p.join(appModulePath, 'features', featureName, switch (wrapper) {
        .page => 'pages',
        _ => 'widgets',
      }, '$targetSnake.dart');

  ComposeWrapperType? get wrapper =>
      ComposeWrapperType.tryParse(targetSnake.split('_').last);
}
