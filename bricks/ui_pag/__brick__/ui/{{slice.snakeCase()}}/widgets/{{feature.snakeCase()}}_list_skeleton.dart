import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'parts/{{feature.snakeCase()}}_list_item_skeleton.dart';

class {{feature.pascalCase()}}ListSkeleton extends StatelessWidget {
  final int itemCount;
  const {{feature.pascalCase()}}ListSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => const {{feature.pascalCase()}}ListItemSkeleton(),
      itemCount: itemCount,
      padding: const EdgeInsets.all(AppSpacing.screen),
      separatorBuilder: (context, index) => AppGap.md,
    );
  }
}
