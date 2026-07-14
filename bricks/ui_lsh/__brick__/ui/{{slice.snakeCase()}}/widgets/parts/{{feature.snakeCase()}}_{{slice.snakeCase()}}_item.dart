import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/{{feature.snakeCase()}}_entity.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Item extends StatelessWidget {
  static const aspectRatio = 10 / 16;
  static const borderRadius = BorderRadius.all(Radius.circular(16));

  final {{feature.pascalCase()}}Entity {{feature.camelCase()}};
  final VoidCallback onTap;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Item({
    super.key,
    required this.{{feature.camelCase()}},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.antiAlias,
          fit: StackFit.expand,
          alignment: Alignment.bottomLeft,
          children: [
            AppNetworkImage(
              url: {{feature.camelCase()}}.imageUrl,
              fit: BoxFit.cover,
              borderRadius: borderRadius,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: {{feature.pascalCase()}}{{slice.pascalCase()}}Item.borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    {{feature.camelCase()}}.name,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  AppGap.xs,
                  Text(
                    {{feature.camelCase()}}.description,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
