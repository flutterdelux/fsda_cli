import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'app_router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,

        /// Module L10n delegate injection
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('id_ID'),
      routerConfig: AppRouter().router,
    );
  }
}
