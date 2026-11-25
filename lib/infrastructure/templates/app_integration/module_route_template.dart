import '../../../core/extensions/feature_param_x.dart';
import '../../../domain/params/app_integration/reg_feature_param.dart';

abstract final class ModuleRouteTemplate {
  static String buildConstants(RegFeatureParam param) {
    final routeNameConstant = '_${param.featureCamel}';
    return '''  static const $routeNameConstant = '${param.featureSnake}';
''';
  }

  static String buildFeatureBaseRoute(RegFeatureParam param) {
    final routeNameConstant = '_${param.featureCamel}';

    return '''

  static RouteBase get ${param.featureCamel}Base => GoRoute(
    path: '/${param.featureSnake}',
    name: $routeNameConstant,
    builder: (context, state) => const NotFoundPage(),
    routes: [
    
    ],
  );
''';
  }
}
