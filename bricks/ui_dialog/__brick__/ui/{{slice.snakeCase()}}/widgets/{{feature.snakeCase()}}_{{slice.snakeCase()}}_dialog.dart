import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/finance_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Dialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Dialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppConfirmationDialog(
      title: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}DialogTitle,
      message: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}DialogMessage,
      cancelText: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}DialogCancel,
      confirmText: l10n.{{feature.camelCase()}}{{slice.pascalCase()}}DialogConfirm,
      onConfirm: onConfirm,
      isDestructive: true,
    );
  }

  Future<void> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => this);
  }
}