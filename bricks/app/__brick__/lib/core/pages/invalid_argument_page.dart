import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../app/app_router.dart';

class InvalidArgumentPage extends StatelessWidget {
  const InvalidArgumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: AppFeedback(
          icon: Icons.error_outline,
          title: l10n.invalidArgumentPageTitle,
          message: l10n.invalidArgumentPageMessage,
          actions: [
            TextButton(
              onPressed: () => AppRouter.toStartup(context),
              child: Text(l10n.backToHome),
            ),
          ],
        ),
      ),
    );
  }
}
