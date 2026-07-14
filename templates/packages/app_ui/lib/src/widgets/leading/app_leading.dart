import 'package:flutter/material.dart';

class AppLeading extends StatelessWidget {
  final Widget child;
  final Size size;
  final Color? backgroundColor;
  final double radius;
  final VoidCallback? onTap;
  const AppLeading({
    super.key,
    required this.child,
    this.size = const Size(36, 36),
    this.backgroundColor,
    this.radius = 36,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      color: backgroundColor ?? colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Align(alignment: Alignment.center, child: child),
        ),
      ),
    );
  }
}
