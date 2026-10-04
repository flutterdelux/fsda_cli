import 'package:flutter/material.dart';

/// Centralized theme configuration for [NavigationRail] in the design system.
class AppNavRailTheme {
  static NavigationRailThemeData standard(ColorScheme colorScheme) {
    return NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      elevation: 0,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        size: 24,
      ),
      selectedLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
