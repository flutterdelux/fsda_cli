import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';
import '../../extensions/text_style_x.dart';

/// A centralized typography system for the Yassist design system.
///
/// Follows Material Design 3 type scale with custom adjustments for
/// line height and information hierarchy using alpha values.
class AppTextTheme {
  static TextTheme standard(ColorScheme colorScheme) => TextTheme(
    // --- Headlines: Used for high-emphasis, short text ---
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
      letterSpacing: -0.5,
    ).withInter,
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
      letterSpacing: -0.5,
    ).withInter,
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      letterSpacing: -0.5,
    ).withInter,

    // --- Titles: Used for medium-emphasis text (AppBar, Card Headers) ---
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ).withInter,
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    ).withInter,
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    ).withInter,

    // --- Body: Used for long-form writing and content ---
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: colorScheme.onSurfaceMedium,
    ).withInter,
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: colorScheme.onSurfaceMedium,
    ).withInter,
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: colorScheme.onSurfaceMedium,
    ).withInter,

    // --- Labels: Used for small, functional text (Buttons, Captions) ---
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: colorScheme.onSurface,
    ).withInter,
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: colorScheme.onSurface,
    ).withInter,
  );
}
