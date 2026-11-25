import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/reg_module_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/params/app_integration/reg_module_param.dart';

abstract final class AppModuleRouteTemplate {
  static ArtifactGenerationModel build(RegModuleParam param) {
    final content =
        '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/pages/not_found_page.dart';

abstract final class ${param.modulePascal}Route {
  static const _${param.moduleCamel} = '${param.moduleCamel}';

  static RouteBase get base => GoRoute(
    path: '/${param.moduleCamel}',
    name: _${param.moduleCamel},
    builder: (context, state) => const NotFoundPage(),
    routes: [],
  );

  static Future<dynamic> to${param.modulePascal}(BuildContext context) {
    return context.pushNamed(_${param.moduleCamel});
  }
}
''';

    return ArtifactGenerationModel(
      name: '${param.modulePascal}Route',
      path: param.appModuleRoutePath,
      content: content,
      typesToImport: {},
      needToExport: false,
    );
  }
}
