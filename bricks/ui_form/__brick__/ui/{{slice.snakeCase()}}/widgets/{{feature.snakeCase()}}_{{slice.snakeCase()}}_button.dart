
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Button extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Button({super.key, required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppSubmitFilledButton(
      text: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}Action,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
    );
  }
}
