import 'package:flutter/material.dart';

import '../../theme/components/app_border_theme.dart';
import '../../tokens/app_spacing.dart';

class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  /// If true, the confirm button will be styled as destructive (e.g., red color).
  final bool isDestructive;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog.adaptive(
      shape: AppBorderTheme.shape,
      title: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(message, style: textTheme.bodyMedium),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDestructive ? colorScheme.error : colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Displays the dialog.
  Future<T?> show<T>(BuildContext context) {
    return showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => this,
    );
  }
}
