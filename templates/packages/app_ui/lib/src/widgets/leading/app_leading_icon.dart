import 'package:flutter/material.dart';

import 'app_leading.dart';

class AppLeadingIcon extends AppLeading {
  AppLeadingIcon({
    super.key,
    required final IconData icon,
    final double iconSize = 20,
    final Color? iconColor,
    final Color? foregroundColor,
    super.backgroundColor,
    super.radius,
    super.size,
    super.onTap,
  }) : super(
         child: _Child(
           icon: icon,
           iconSize: iconSize,
           iconColor: iconColor,
           foregroundColor: foregroundColor,
         ),
       );
}

class _Child extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final Color? foregroundColor;

  const _Child({
    required this.icon,
    required this.iconSize,
    this.iconColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
      icon,
      size: iconSize,
      color: iconColor ?? colorScheme.onSurfaceVariant,
    );
  }
}
