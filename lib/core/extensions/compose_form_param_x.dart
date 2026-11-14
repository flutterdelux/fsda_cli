import 'package:path/path.dart' as p;

import '../../domain/params/app_integration/compose_form_param.dart';

extension ComposeFormParamX on ComposeFormParam {
  String get uiSlicePath => p.join(featurePath ?? '', 'ui', uiSlice, 'widgets');

  String get logicSlicePath => p.join(featurePath ?? '', 'logic', logicSlice);
}
