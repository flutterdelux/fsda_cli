import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class DestinationPopularErrorFeedback extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const DestinationPopularErrorFeedback({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppErrorFeedback(
      title: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}ErrorTitle,
      message: message,
      retryText: appL10n.retry,
      onRetry: onRetry,
    );
  }
}
