import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/{{feature.snakeCase()}}_entity.dart';
import 'parts/{{feature.snakeCase()}}_{{slice.snakeCase()}}_item.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Content extends StatelessWidget {
  static const height = 280.0;

  final List<{{feature.pascalCase()}}Entity> list;
  final void Function({{feature.pascalCase()}}Entity item) onItemTap;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Content({
    super.key,
    required this.list,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (context, index) => AppGap.md,
        itemBuilder: (context, index) {
          final {{feature.camelCase()}} = list[index];
          return {{feature.pascalCase()}}{{slice.pascalCase()}}Item(
            {{feature.camelCase()}}: {{feature.camelCase()}},
            onTap: () => onItemTap({{feature.camelCase()}}),
          );
        },
      ),
    );
  }
}
