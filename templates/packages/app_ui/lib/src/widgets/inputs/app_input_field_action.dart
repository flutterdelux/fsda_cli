import 'package:flutter/material.dart';

class AppInputFieldAction extends StatelessWidget {
  final bool hasValue;
  final VoidCallback? onClear;
  final VoidCallback? onPressed;

  const AppInputFieldAction({
    super.key,
    required this.hasValue,
    this.onClear,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (hasValue) {
      return IconButton(onPressed: onClear, icon: const Icon(Icons.clear));
    }
    return IconButton(onPressed: onPressed, icon: const Icon(Icons.add));
  }
}
