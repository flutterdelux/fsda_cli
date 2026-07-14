import 'package:flutter/material.dart';

/// Extensions for the [Color] class to provide utility methods
/// for hex conversion and manipulation.
extension ColorX on Color {
  /// Converts the color to an uppercase hex string.
  ///
  /// [includeHash] - whether to prefix the string with '#'.
  /// [includeAlpha] - whether to include the 2-character alpha (opacity) value.
  ///
  /// Output format: #AARRGGBB or #RRGGBB
  String toHex({bool includeHash = false, bool includeAlpha = true}) {
    final String alpha = _toRadix(a * 255);
    final String red = _toRadix(r * 255);
    final String green = _toRadix(g * 255);
    final String blue = _toRadix(b * 255);

    final buffer = StringBuffer();
    if (includeHash) buffer.write('#');
    if (includeAlpha) buffer.write(alpha);
    buffer.write(red);
    buffer.write(green);
    buffer.write(blue);

    return buffer.toString().toUpperCase();
  }

  /// Helper to convert a double 0-255 color channel to a 2-character hex string.
  String _toRadix(double value) {
    return value.toInt().toRadixString(16).padLeft(2, '0');
  }
}
