import 'package:flutter/material.dart';

import 'app_leading.dart';

class AppLeadingId extends AppLeading {
  AppLeadingId({
    super.key,
    required final String id,
    final Color? foregroundColor,
    super.backgroundColor,
    super.radius,
    super.size,
    super.onTap,
  }) : super(
         child: _Child(id: id, foregroundColor: foregroundColor),
       );
}

class _Child extends StatelessWidget {
  final String id;
  final Color? foregroundColor;

  const _Child({required this.id, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Text(
      id.isNotEmpty ? id.split('').take(4).join() : 'N/A',
      style: textTheme.titleSmall?.copyWith(
        color: foregroundColor ?? colorScheme.onSurfaceVariant,
      ),
    );
  }
}
