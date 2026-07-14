import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const {{feature.pascalCase()}}DetailError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppErrorFeedback(
      title: l10n.{{feature.camelCase()}}DetailErrorTitle,
      message: message,
      onRetry: onRetry,
      retryText: appL10n.retry,
    );
  }
}
