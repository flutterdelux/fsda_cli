import 'package:flutter/material.dart';

/// Extensions for [ColorScheme] to provide additional semantic colors
/// not included in the standard Material Design 3 palette.
extension ColorSchemeX on ColorScheme {
  Color get success => brightness == Brightness.light
      ? const Color(0xFF059669)
      : const Color(0xFF10B981);

  Color get onSuccess => brightness == Brightness.light
      ? const Color(0xffFFFFFF)
      : const Color(0xffFFFFFF);

  Color get warning => brightness == Brightness.light
      ? const Color(0xFFF59E0B)
      : const Color(0xFFFBBF24);

  Color get onWarning => brightness == Brightness.light
      ? const Color(0xffFFFFFF)
      : const Color(0xffFFFFFF);

  Color get info => brightness == Brightness.light
      ? const Color(0xFF06B6D4)
      : const Color(0xFF38BDF8);

  Color get onInfo => brightness == Brightness.light
      ? const Color(0xffFFFFFF)
      : const Color(0xffFFFFFF);

  // ================= SHIMMER COLORS =================

  Color get shimmerBase => brightness == Brightness.light
      // Light: Made slightly darker & desaturated grey-blue to contrast against surfaceContainerLight
      ? const Color(0xFFDBE5E8)
      // Dark: Refined to blend naturally over surfaceContainerDark
      : const Color(0xFF222C30);

  Color get shimmerHighlight => brightness == Brightness.light
      // Light: Pure white flash for maximum animation visibility
      ? const Color(0xFFFFFFFF)
      // Dark: Subtle lighter tint for the moving flash effect
      : const Color(0xFF2D3B40);

  // ================= SEMANTIC OPAQUE COLORS =================

  /// Equivalent to 30% opacity
  Color get onSurfaceThin => brightness == Brightness.light
      ? const Color(0xFF9AA5A8)
      : const Color(0xFF566064);

  /// Equivalent to 50% opacity
  Color get onSurfaceLight => brightness == Brightness.light
      ? const Color(0xFF6F7B7E)
      : const Color(0xFF828F93);

  /// Equivalent to 70% opacity
  Color get onSurfaceMedium => brightness == Brightness.light
      ? const Color(0xFF3A4244)
      : const Color(0xFFB1BABC);
}
