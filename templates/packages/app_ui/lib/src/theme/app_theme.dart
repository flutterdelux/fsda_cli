import 'package:flutter/material.dart';

import '../extensions/color_scheme_x.dart';
import '../tokens/app_typography.dart';
import 'components/app_border_theme.dart';
import 'components/app_button_theme.dart';
import 'components/app_card_theme.dart';
import 'components/app_color_theme.dart';
import 'components/app_divider_theme.dart';
import 'components/app_input_theme.dart';
import 'components/app_nav_bar_theme.dart';
import 'components/app_text_theme.dart';

/// The central point of theme management for the entire application.
///
/// This class assembles all tokens and component themes into a unified
/// [ThemeData] for both Light and Dark modes.
class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = brightness == Brightness.dark
        ? AppColorTheme.darkScheme
        : AppColorTheme.lightScheme;

    final baseTextTheme = AppTextTheme.standard(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // Layout Colors
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,

      // Component Themes
      filledButtonTheme: AppButtonTheme.filled(colorScheme),
      outlinedButtonTheme: AppButtonTheme.outlined(colorScheme),
      textButtonTheme: AppButtonTheme.text(colorScheme),
      cardTheme: AppCardTheme.standard(colorScheme),
      navigationBarTheme: AppNavBarTheme.standard(colorScheme),

      // Typography
      fontFamily: AppTypography.fontFamily,
      package: AppTypography.package,
      textTheme: baseTextTheme,

      // AppBar Customization
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        // Prevents AppBar from changing color when scrolled
        surfaceTintColor: Colors.transparent,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      inputDecorationTheme: AppInputTheme.standard(
        colorScheme: colorScheme,
        textTheme: baseTextTheme,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: AppInputTheme.standard(
          colorScheme: colorScheme,
          textTheme: baseTextTheme,
        ),

        menuStyle: MenuStyle(
          shape: WidgetStatePropertyAll(AppBorderTheme.shape),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: MenuItemButton.styleFrom(
          visualDensity: const VisualDensity(vertical: 0),
          backgroundColor: colorScheme.surfaceContainerHighest,
          textStyle: baseTextTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),

      dividerTheme: AppDividerTheme.standard(colorScheme),

      listTileTheme: ListTileThemeData(iconColor: colorScheme.onSurfaceMedium),
    );
  }
}
