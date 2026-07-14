import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/pages/not_found_page.dart';
import 'dashboard/dashboard_route.dart';
import 'startup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static const startup = 'startup';
  static const startupPath = '/';

  late final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: startupPath,
    redirect: _redirect,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      _mainRoute,
      DashboardRoute.base,
      // ...inject here
    ],
  );

  FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
    return null;
  }

  RouteBase get _mainRoute => GoRoute(
    path: startupPath,
    name: startup,
    builder: (context, state) => const Startup(),
  );

  static void toStartup(BuildContext context) {
    context.goNamed(startup);
  }
}
