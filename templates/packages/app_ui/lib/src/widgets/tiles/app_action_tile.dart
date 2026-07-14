import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';
import '../../tokens/app_spacing.dart';

class AppActionTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? leadingIcon;
  final bool includeChevron;

  const AppActionTile({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onTap,
    this.includeChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      leading: leadingIcon,
      title: Text(
        title,
        style: textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: includeChevron
          ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceLight)
          : null,
    );
  }
}
