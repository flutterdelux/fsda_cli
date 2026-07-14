import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/pages/not_found_page.dart';

abstract final class {{module.pascalCase()}}Route {
  static const _{{module.camelCase()}} = '{{module.camelCase()}}';

  static RouteBase get base => GoRoute(
    path: '/{{module.camelCase()}}',
    name: _{{module.camelCase()}},
    builder: (context, state) => const NotFoundPage(),
    routes: [],
  );

  static Future<dynamic> to{{module.pascalCase()}}(BuildContext context) {
    return context.pushNamed(_{{module.camelCase()}});
  }
}
