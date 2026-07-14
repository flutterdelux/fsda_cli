import 'package:flutter/material.dart';

class AppDividerTheme {
  static DividerThemeData standard(ColorScheme colorScheme) => DividerThemeData(
    color: colorScheme.outline.withValues(alpha: .3),
    thickness: 0.5,
    space: 0,
  );
}
