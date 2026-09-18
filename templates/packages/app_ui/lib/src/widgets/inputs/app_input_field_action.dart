import 'package:flutter/material.dart';

class AppInputFieldAction extends StatelessWidget {
  final bool hasValue;
  final VoidCallback? onClear;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppInputFieldAction({
    super.key,
    required this.hasValue,
    this.onClear,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (hasValue) {
      return IconButton(onPressed: onClear, icon: const Icon(Icons.clear));
    }
    return IconButton(onPressed: onPressed, icon: Icon(icon ?? Icons.add));
  }
}
