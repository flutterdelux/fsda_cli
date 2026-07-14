import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/{{feature.snakeCase()}}_entity.dart';
import 'parts/{{feature.snakeCase()}}_list_item.dart';

class {{feature.pascalCase()}}ListContent extends StatelessWidget {
  final List<{{feature.pascalCase()}}Entity> list;
  final void Function({{feature.pascalCase()}}Entity item) onItemTap;
  const {{feature.pascalCase()}}ListContent({
    super.key,
    required this.list,
    required this.onItemTap,
  });

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
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final {{feature.camelCase()}} = list[index];
        return {{feature.pascalCase()}}ListItem(
          index: index,
          {{feature.camelCase()}}: {{feature.camelCase()}},
          onTap: () => onItemTap({{feature.camelCase()}}),
        );
      },
    );
  }
}
