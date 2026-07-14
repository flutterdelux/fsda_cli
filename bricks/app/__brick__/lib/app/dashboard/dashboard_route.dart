import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/dashboard.dart';
import 'pages/home_page.dart';

class DashboardRoute {
  static const home = 'home';
  static const homePath = '/home';
  static const search = 'search';
  static const account = 'account';

  static RouteBase get base => StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return Dashboard(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: home,
            path: homePath,
            builder: (context, state) => const HomePage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: search,
            path: '/search',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Search'))),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: account,
            path: '/account',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Account'))),
          ),
        ],
      ),
    ],
  );

  static void toHome(BuildContext context) {
    context.goNamed(home);
  }

  static void toSearch(BuildContext context) {
    context.goNamed(search);
  }

  static void toAccount(BuildContext context) {
    context.goNamed(account);
  }
}
