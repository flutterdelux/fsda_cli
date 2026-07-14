import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/{{feature.snakeCase()}}_entity.dart';

class {{feature.pascalCase()}}DetailContent extends StatelessWidget {
  final {{feature.pascalCase()}}Entity {{feature.camelCase()}};
  final Future<void> Function() onPullRefresh;
  const {{feature.pascalCase()}}DetailContent({
    super.key,
    required this.{{feature.camelCase()}},
    required this.onPullRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator.adaptive(
      onRefresh: onPullRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            '{{feature.camelCase()}}.title',
            style: textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
