import 'package:flutter/material.dart';

/// Extension to convert hex strings directly into [Color] objects.
extension StringColorX on String {
  /// Converts a hex string to a [Color].
  ///
  /// Supports:
  /// - RGB: `"#RRGGBB"` or `"RRGGBB"`
  /// - ARGB: `"#AARRGGBB"` or `"AARRGGBB"`
  ///
  /// Returns [Colors.transparent] if the format is invalid instead of crashing.
  Color toColor() {
    final hexCode = replaceAll('#', '').trim();

    try {
      final length = hexCode.length;

      if (length == 6) {
        // Add full opacity (FF) for 6-digit hex
        return Color(int.parse('FF$hexCode', radix: 16));
      } else if (length == 8) {
        // Use as is for 8-digit hex (AARRGGBB)
        return Color(int.parse(hexCode, radix: 16));
      }
    } catch (e) {
      // Invalid format, will return transparent below
    }

    // Return fallback to prevent red screen of death
    return Colors.transparent;
  }
}
