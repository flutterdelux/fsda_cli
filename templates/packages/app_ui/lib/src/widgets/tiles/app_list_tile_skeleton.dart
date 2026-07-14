import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../feedback/app_shimmer.dart';

class AppListTileSkeleton extends StatelessWidget {
  final bool includeLeading;
  final bool includeSubtitle;
  final bool includeTrailing;

  const AppListTileSkeleton({
    super.key,
    this.includeLeading = true,
    this.includeSubtitle = true,
    this.includeTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      leading: includeLeading ? AppShimmer.circle(size: 32) : null,
      title: const Align(
        alignment: .centerLeft,
        child: AppShimmer(width: 200, height: 16),
      ),
      subtitle: includeSubtitle
          ? const UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: AppShimmer(width: 150, height: 12),
            )
          : null,
      trailing: includeTrailing
          ? const UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: AppShimmer(width: 16, height: 16),
            )
          : null,
    );
  }
}
