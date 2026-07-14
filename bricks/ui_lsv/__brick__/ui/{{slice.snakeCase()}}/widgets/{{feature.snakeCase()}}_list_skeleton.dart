import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'parts/{{feature.snakeCase()}}_list_item_skeleton.dart';

class {{feature.pascalCase()}}ListSkeleton extends StatelessWidget {
  final int itemCount;
  const {{feature.pascalCase()}}ListSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        AppSpacing.screen + padding.bottom,
      ),
      itemBuilder: (context, index) {
        return const {{feature.pascalCase()}}ListItemSkeleton();
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: itemCount,
    );
  }
}
