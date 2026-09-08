import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Dialog extends StatelessWidget {
  /// Use `{{feature.pascalCase()}}{{slice.pascalCase()}}Form`
  final Widget form;

  /// Use `{{feature.pascalCase()}}{{slice.pascalCase()}}Button`
  final Widget submitButton;

  final Widget? error;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}Dialog({
    super.key,
    required this.form,
    required this.submitButton,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SimpleDialog(
      title: Text(
        l10n.{{feature.camelCase()}}{{slice.pascalCase()}}Title,
        style: textTheme.titleLarge,
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.screen,
        AppSpacing.screen,
        0,
      ),
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.{{feature.camelCase()}}{{slice.pascalCase()}}Description,
            style: textTheme.bodyMedium,
          ),
        ),
        form,
        AppGap.md,
        if (error != null) ...[const Divider(), error!],
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              submitButton,
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(appL10n.close),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
