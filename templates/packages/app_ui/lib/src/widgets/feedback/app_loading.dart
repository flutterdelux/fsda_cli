import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
