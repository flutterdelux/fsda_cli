import '../../../core/extensions/app_integration_param_x.dart';
import '../../../domain/params/app_integration/reg_feature_param.dart';

abstract final class ModuleRouteTemplate {
  /// Konstanta nama & path route
  static String buildConstants(RegFeatureParam param) {
    final routeNameConstant = '_${param.featureCamel}';
    return '''  static const $routeNameConstant = '${param.featureSnake}';
''';
  }

  /// Base route getter & helper helper push route
  static String buildFeatureBaseRoute(RegFeatureParam param) {
    final routeNameConstant = '_${param.featureCamel}';

    return '''

  static RouteBase get ${param.featureCamel}Base => GoRoute(
    path: '/${param.featureSnake}',
    name: $routeNameConstant,
    builder: (context, state) => const NotFoundPage(),
    routes: [
      // Sub routes for ${param.featurePascal} (diisi manual oleh dev)
    ],
  );
''';
  }
}
