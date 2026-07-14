import 'package:flutter/material.dart';

import '../../tokens/app_colors.dart'; // Adjust path based on your project structure

class AppColorTheme {
  const AppColorTheme._();

  static ColorScheme get lightScheme => const ColorScheme.light(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.onPrimaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.onSecondaryLight,
    surface: AppColors.surfaceLight,
    surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
    surfaceContainerLow: AppColors.surfaceContainerLowLight,
    surfaceContainer: AppColors.surfaceContainerLight,
    surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
    onSurface: AppColors.onSurfaceLight,
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
  );

  static ColorScheme get darkScheme => const ColorScheme.dark(
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.onSecondaryDark,
    surface: AppColors.surfaceDark,
    surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
    surfaceContainerLow: AppColors.surfaceContainerLowDark,
    surfaceContainer: AppColors.surfaceContainerDark,
    surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
    onSurface: AppColors.onSurfaceDark,
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
  );
}
