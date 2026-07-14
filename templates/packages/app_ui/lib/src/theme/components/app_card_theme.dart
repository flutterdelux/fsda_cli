import 'package:flutter/material.dart';

import 'app_border_theme.dart';

/// A centralized theme configuration for [Card] widgets in the app design system.
class AppCardTheme {
  static CardThemeData standard(ColorScheme colorScheme) => CardThemeData(
    color: colorScheme.surfaceContainer,
    elevation: 0,
    shape: AppBorderTheme.shape,
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  );
}
