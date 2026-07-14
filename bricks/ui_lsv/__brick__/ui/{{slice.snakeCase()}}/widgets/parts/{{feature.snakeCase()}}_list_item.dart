import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/{{feature.snakeCase()}}_entity.dart';

class {{feature.pascalCase()}}ListItem extends StatelessWidget {
  final int index;
  final {{feature.pascalCase()}}Entity {{feature.camelCase()}};
  final void Function() onTap;
  const {{feature.pascalCase()}}ListItem({
    super.key,
    required this.index,
    required this.{{feature.camelCase()}},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: AppLeadingIndex(number: index + 1),
      title: '{{feature.camelCase()}}.title',
      subtitle: '{{feature.camelCase()}}.content',
      includeChevron: true,
      onTap: onTap,
    );
  }
}
