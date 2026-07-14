import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';
import '../layouts/app_gap.dart';

class AppFeedback extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? visual;
  final IconData? icon;
  final double iconSize;
  final List<Widget>? actions;

  /// Priority of what to display: [visual] > [icon] > null
  const AppFeedback({
    super.key,
    required this.title,
    this.message,
    this.visual,
    this.icon,
    this.iconSize = 64,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...[
            ?visual,
            if (visual == null && icon != null)
              Icon(icon, size: iconSize, color: colorScheme.onSurfaceMedium),
            AppGap.lg,
          ],
          Text(
            title,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            AppGap.sm,
            Text(
              message!,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (actions != null) ...[
            AppGap.md,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
