import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}ItemSkeleton extends StatelessWidget {
  const {{feature.pascalCase()}}{{slice.pascalCase()}}ItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListTileSkeleton();
  }
}
