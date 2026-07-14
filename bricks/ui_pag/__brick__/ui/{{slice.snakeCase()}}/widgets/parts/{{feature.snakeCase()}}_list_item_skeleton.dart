import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class {{feature.pascalCase()}}ListItemSkeleton extends StatelessWidget {
  const {{feature.pascalCase()}}ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListTileSkeleton();
  }
}
