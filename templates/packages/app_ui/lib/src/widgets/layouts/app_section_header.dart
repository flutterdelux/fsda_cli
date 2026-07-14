import 'package:flutter/material.dart';

import '../texts/app_clickable_text.dart';

class AppSectionHeader extends StatelessWidget {
  final String titleText;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const AppSectionHeader({
    super.key,
    required this.titleText,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(titleText, style: textTheme.titleMedium)),
        if (actionText != null)
          AppClickableText(text: actionText!, onTap: onActionPressed),
      ],
    );
  }
}
