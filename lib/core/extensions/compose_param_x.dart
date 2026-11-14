import 'package:path/path.dart' as p;

import '../../domain/enums/compose_wrapper_type.dart';
import '../../domain/params/app_integration/compose_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'app_integration_param_x.dart';

extension ComposeParamX on ComposeParam {
  String get logicFlowSlicePath =>
      p.join(featurePath ?? '', 'logic', logicFlowSlice);

  String get targetSnake => target;
  String get targetPascal => targetSnake.pascalCase;
  String get targetPath =>
      p.join(appModulePath, 'features', featureName, switch (wrapper) {
        ComposeWrapperType.page => 'pages',
        _ => 'widgets',
      }, '$targetSnake.dart');

  ComposeWrapperType? get wrapper =>
      ComposeWrapperType.tryParse(targetSnake.split('_').last);
}
