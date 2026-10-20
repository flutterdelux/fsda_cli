import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/{{entity.snakeCase()}}.dart';
import 'parts/{{feature.snakeCase()}}_{{slice.snakeCase()}}_item.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Content extends StatelessWidget {
  final List<{{entity.pascalCase()}}> list;
  final void Function({{entity.pascalCase()}} item) onItemTap;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Content({
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
        final {{object.camelCase()}} = list[index];
        return {{feature.pascalCase()}}{{slice.pascalCase()}}Item(
          index: index,
          {{object.camelCase()}}: {{object.camelCase()}},
          onTap: () => onItemTap({{object.camelCase()}}),
        );
      },
    );
  }
}
