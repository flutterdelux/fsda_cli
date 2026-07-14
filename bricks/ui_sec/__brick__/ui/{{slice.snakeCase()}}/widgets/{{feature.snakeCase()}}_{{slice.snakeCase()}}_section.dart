import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Section extends StatelessWidget {
  final Widget content;
  final VoidCallback? onSeeAllPressed;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Section({
    super.key,
    required this.content,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppSection(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: AppSectionHeader(
          titleText: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}Title,
          actionText: appL10n.seeAll,
          onActionPressed: onSeeAllPressed,
        ),
      ),
      content: content,
    );
  }
}
