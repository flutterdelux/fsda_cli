import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/{{feature.snakeCase()}}_entity.dart';

class {{feature.pascalCase()}}ListItem extends StatelessWidget {
  final {{feature.pascalCase()}}Entity {{feature.camelCase()}};
  final int number;
  final VoidCallback? onTap;
  const {{feature.pascalCase()}}ListItem({
    super.key,
    required this.{{feature.camelCase()}},
    required this.number,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: AppLeadingIndex(number: number),
      title: '{{feature.camelCase()}}.title',
      subtitle: 'subtitle',
      onTap: onTap,
      includeChevron: true,
    );
  }
}
