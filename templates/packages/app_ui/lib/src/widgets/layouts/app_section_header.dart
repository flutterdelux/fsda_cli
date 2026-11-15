import 'package:flutter/material.dart';

import '../texts/app_clickable_text.dart';

class AppSectionHeader extends StatelessWidget {
  final String titleText;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsetsGeometry padding;

  const AppSectionHeader({
    super.key,
    required this.titleText,
    this.actionText,
    this.onActionPressed,
    this.padding = EdgeInsetsGeometry.zero,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(titleText, style: textTheme.titleMedium)),
          if (actionText != null)
            AppClickableText(text: actionText!, onTap: onActionPressed),
        ],
      ),
    );
  }
}
