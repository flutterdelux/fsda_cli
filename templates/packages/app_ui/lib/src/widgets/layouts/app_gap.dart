import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../tokens/app_spacing.dart';

class AppGap extends StatelessWidget {
  final double space;
  const AppGap({super.key, required this.space});

  /// **`2`**
  static const AppGap xxs = AppGap(space: AppSpacing.xxs);

  /// **`4`**
  static const AppGap xs = AppGap(space: AppSpacing.xs);

  /// **`8`**
  static const AppGap sm = AppGap(space: AppSpacing.sm);

  /// **`16`**
  static const AppGap md = AppGap(space: AppSpacing.md);

  /// **`24`**
  static const AppGap lg = AppGap(space: AppSpacing.lg);

  /// **`32`**
  static const AppGap xl = AppGap(space: AppSpacing.xl);

  /// **`40`**
  static const AppGap xxl = AppGap(space: AppSpacing.xxl);

  @override
  Widget build(BuildContext context) {
    return Gap(space);
  }
}
