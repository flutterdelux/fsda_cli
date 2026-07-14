import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_content.dart';
import 'parts/{{feature.snakeCase()}}_{{slice.snakeCase()}}_item_skeleton.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Skeleton extends StatelessWidget {
  final int itemCount;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Skeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: {{feature.pascalCase()}}{{slice.pascalCase()}}Content.height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (context, index) => AppGap.md,
        itemBuilder: (context, index) {
          return const {{feature.pascalCase()}}{{slice.pascalCase()}}ItemSkeleton();
        },
      ),
    );
  }
}
