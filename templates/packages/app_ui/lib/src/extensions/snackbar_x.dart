import 'package:flutter/material.dart';

import '../theme/components/app_border_theme.dart';
import '../tokens/app_spacing.dart';
import 'color_scheme_x.dart';

/// Extension on [BuildContext] to provide a unified way to show system feedbacks.
extension SnackbarX on BuildContext {
  void showNetralSnackbar(String message, {bool isFloating = true}) {
    final colorScheme = Theme.of(this).colorScheme;
    _show(
      message: message,
      backgroundColor: colorScheme.info,
      textColor: colorScheme.onInfo,
      isFloating: isFloating,
    );
  }

  /// Shows a red-themed snackbar for error messages.
  void showErrorSnackbar(String message, {bool isFloating = true}) {
    final colorScheme = Theme.of(this).colorScheme;
    _show(
      message: message,
      backgroundColor: colorScheme.error,
      textColor: colorScheme.onError,
      isFloating: isFloating,
    );
  }

  /// Shows a green-themed snackbar for success messages.
  ///
  /// Utilizes the [ColorSchemeX] extension for automatic brightness handling.
  void showSuccessSnackbar(String message, {bool isFloating = true}) {
    final colorScheme = Theme.of(this).colorScheme;
    _show(
      message: message,
      backgroundColor: colorScheme.success,
      textColor: colorScheme.onSuccess,
      isFloating: isFloating,
    );
  }

  void _show({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    bool isFloating = true,
  }) {
    final textTheme = Theme.of(this).textTheme;

    ScaffoldMessenger.of(this).clearSnackBars();

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: isFloating
            ? SnackBarBehavior.floating
            : SnackBarBehavior.fixed,
        shape: AppBorderTheme.shape,
        margin: isFloating ? const EdgeInsets.all(AppSpacing.md) : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
