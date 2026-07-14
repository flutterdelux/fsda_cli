import 'package:flutter/material.dart';

import 'app_feedback.dart';

class AppErrorFeedback extends StatelessWidget {
  final String title;
  final String? message;
  final String retryText;
  final VoidCallback? onRetry;

  const AppErrorFeedback({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryText = "Retry",
  });

  @override
  Widget build(BuildContext context) {
    return AppFeedback(
      icon: Icons.error_outline,
      title: title,
      message: message,
      actions: onRetry != null
          ? [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText),
              ),
            ]
          : null,
    );
  }
}
