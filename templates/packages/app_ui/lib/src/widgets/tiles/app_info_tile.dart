import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';
import '../../tokens/app_spacing.dart';

class AppInfoTile extends StatelessWidget {
  final String title;
  final String data;
  final (int, int) flexRatio;
  final bool includeChevron;
  final VoidCallback? onTap;

  const AppInfoTile({
    super.key,
    required this.title,
    required this.data,
    this.flexRatio = (1, 1),
    this.includeChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      title: Row(
        children: [
          Flexible(
            flex: flexRatio.$1,
            fit: FlexFit.tight,
            child: Text(
              title,

              style: textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
          Flexible(
            flex: flexRatio.$2,
            fit: FlexFit.tight,
            child: Text(
              data,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      horizontalTitleGap: 0,
      trailing: includeChevron
          ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceLight)
          : null,
      onTap: onTap,
    );
  }
}
