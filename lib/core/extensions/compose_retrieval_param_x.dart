import 'package:path/path.dart' as p;

import '../../domain/params/app_integration/compose_retrieval_param.dart';

extension ComposeRetrievalParamX on ComposeRetrievalParam {
  String get uiSlicePath => p.join(featurePath ?? '', 'ui', uiSlice, 'widgets');
}
