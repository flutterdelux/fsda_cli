import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}ListEmptyFeedback extends StatelessWidget {
  final VoidCallback onRefresh;
  const {{feature.pascalCase()}}ListEmptyFeedback({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppEmptyFeedback(
      title: l10n.{{feature.camelCase()}}ListEmptyTitle,
      message: l10n.{{feature.camelCase()}}ListEmptyMessage,
      onRefresh: onRefresh,
      refreshText: appL10n.refresh,
    );
  }
}
