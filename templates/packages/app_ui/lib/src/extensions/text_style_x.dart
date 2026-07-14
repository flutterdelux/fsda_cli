import 'package:flutter/material.dart';

import '../tokens/app_typography.dart';

/// {@template text_style_x}
/// Extension on TextStyle to easily apply the Inter font family from AppTypography.
/// This allows for a more fluent API when customizing text styles in the app.
/// {@endtemplate}
extension TextStyleX on TextStyle {
  /// Applies the Inter font family to the existing TextStyle.
  /// This is a convenient way to ensure all text styles in the app use the same font without having to specify it every time.
  TextStyle get withInter {
    return copyWith(
      fontFamily: AppTypography.fontFamily,
      package: AppTypography.package,
    );
  }
}
