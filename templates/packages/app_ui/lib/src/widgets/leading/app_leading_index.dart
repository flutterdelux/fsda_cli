import 'package:flutter/material.dart';

import 'app_leading.dart';

class AppLeadingIndex extends AppLeading {
  AppLeadingIndex({
    super.key,
    required final int number,
    final Color? foregroundColor,
    super.backgroundColor,
    super.radius,
    super.size,
    super.onTap,
  }) : super(
         child: _Child(number: number, foregroundColor: foregroundColor),
       );
}

class _Child extends StatelessWidget {
  final int number;
  final Color? foregroundColor;

  const _Child({required this.number, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Text(
      '$number',
      style: textTheme.titleSmall?.copyWith(
        color: foregroundColor ?? colorScheme.onSurfaceVariant,
      ),
    );
  }
}
