import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class AppSubmitFilledButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;

  const AppSubmitFilledButton({
    super.key,
    this.isLoading = false,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const AppLoadingMini() : Text(text),
    );
  }
}
