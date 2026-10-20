import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/{{entity.snakeCase()}}.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Item extends StatelessWidget {
  final int index;
  final {{entity.pascalCase()}} {{object.camelCase()}};
  final void Function() onTap;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Item({
    super.key,
    required this.index,
    required this.{{object.camelCase()}},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: AppLeadingIndex(number: index + 1),
      title: '{{object.camelCase()}}.title',
      subtitle: '{{object.camelCase()}}.content',
      includeChevron: true,
      onTap: onTap,
    );
  }
}
