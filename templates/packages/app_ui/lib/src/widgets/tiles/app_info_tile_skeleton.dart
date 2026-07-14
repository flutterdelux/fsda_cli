import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../feedback/app_shimmer.dart';

class AppInfoTileSkeleton extends StatelessWidget {
  const AppInfoTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      title: AppShimmer(width: 100, height: 14),
      trailing: AppShimmer(width: 100, height: 14),
    );
  }
}
