import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';
import '../../tokens/app_radius.dart';

class AppInputTheme {
  static InputDecorationThemeData standard({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final decoration = _getDecoration(
      colorScheme: colorScheme,
      textTheme: textTheme,
    );
    return InputDecorationThemeData(
      fillColor: decoration.fillColor,
      filled: decoration.filled ?? false,
      isDense: decoration.isDense ?? false,
      contentPadding: decoration.contentPadding,
      visualDensity: decoration.visualDensity,
      border: decoration.border,
      enabledBorder: decoration.enabledBorder,
      focusedBorder: decoration.focusedBorder,
      hintStyle: decoration.hintStyle,
      prefixStyle: decoration.prefixStyle,
      prefixIconColor: decoration.prefixIconColor,
      prefixIconConstraints: decoration.prefixIconConstraints,
      suffixStyle: decoration.suffixStyle,
      suffixIconColor: decoration.suffixIconColor,
      suffixIconConstraints: decoration.prefixIconConstraints,
    );
  }

  static OutlineInputBorder get _baseBorder => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
    borderSide: BorderSide.none,
  );

  static InputDecoration _getDecoration({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    String? hintText,
  }) {
    return InputDecoration(
      fillColor: colorScheme.surfaceContainer,
      filled: true,
      visualDensity: const VisualDensity(vertical: 0),
      contentPadding: const EdgeInsets.all(16),
      border: _baseBorder,
      enabledBorder: _baseBorder,
      focusedBorder: _baseBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      hintText: hintText,
      hintStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceThin,
      ),
      prefixStyle: TextStyle(color: colorScheme.onSurfaceMedium),
      prefixIconColor: colorScheme.onSurfaceMedium,
      prefixIconConstraints: const BoxConstraints(maxWidth: 54, minWidth: 54),
      suffixStyle: TextStyle(color: colorScheme.onSurfaceMedium),
      suffixIconColor: colorScheme.onSurfaceMedium,
      suffixIconConstraints: const BoxConstraints(maxWidth: 54, minWidth: 54),
    );
  }
}
