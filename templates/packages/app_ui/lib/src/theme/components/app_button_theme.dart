import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import 'app_border_theme.dart';

/// A collection of button themes for the app design system.
class AppButtonTheme {
  static FilledButtonThemeData filled(ColorScheme colorScheme) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          visualDensity: const VisualDensity(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: AppBorderTheme.shape,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: _textStyle,
        ),
      );

  static OutlinedButtonThemeData outlined(ColorScheme colorScheme) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          visualDensity: const VisualDensity(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: AppBorderTheme.shape,
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          textStyle: _textStyle,
        ),
      );

  static TextButtonThemeData text(ColorScheme colorScheme) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          visualDensity: const VisualDensity(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: AppBorderTheme.shape,
          foregroundColor: colorScheme.primary,
        ),
      );

  static TextStyle get _textStyle =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}
