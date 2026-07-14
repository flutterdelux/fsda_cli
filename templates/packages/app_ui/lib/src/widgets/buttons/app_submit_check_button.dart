import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class AppSubmitCheckButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const AppSubmitCheckButton({
    super.key,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? const AppLoadingMini() : const Icon(Icons.check),
    );
  }
}
