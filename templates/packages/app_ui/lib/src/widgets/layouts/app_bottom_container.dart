import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

class AppBottomContainer extends StatelessWidget {
  final Widget child;
  final bool withSafeArea;
  final EdgeInsetsGeometry padding;
  final bool withShadow;
  const AppBottomContainer({
    super.key,
    required this.child,
    this.withSafeArea = true,
    this.padding = const EdgeInsets.all(AppSpacing.screen),
    this.withShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: .1)),
        ),
        boxShadow: _buildShadow(context),
      ),
      child: withSafeArea ? SafeArea(child: child) : child,
    );
  }

  List<BoxShadow>? _buildShadow(BuildContext context) {
    if (!withShadow) return null;
    final colorScheme = Theme.of(context).colorScheme;
    return [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: .1),
        blurRadius: 8,
        offset: const Offset(0, -4),
      ),
    ];
  }
}
