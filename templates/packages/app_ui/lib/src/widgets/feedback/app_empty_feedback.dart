import 'package:flutter/material.dart';

import 'app_feedback.dart';

class AppEmptyFeedback extends StatelessWidget {
  final String title;
  final String? message;
  final String refreshText;
  final VoidCallback? onRefresh;

  const AppEmptyFeedback({
    super.key,
    required this.title,
    this.message,
    this.onRefresh,
    this.refreshText = "Refresh",
  });

  @override
  Widget build(BuildContext context) {
    return AppFeedback(
      icon: Icons.inbox_outlined,
      title: title,
      message: message,
      actions: onRefresh != null
          ? [
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text(refreshText),
              ),
            ]
          : null,
    );
  }
}
