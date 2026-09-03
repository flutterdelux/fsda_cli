import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppSection extends StatelessWidget {
  /// use `AppSectionHeader` for global app style
  final Widget header;
  final double headerGap;
  final Widget child;
  final EdgeInsetsGeometry margin;

  const AppSection({
    super.key,
    required this.header,
    required this.child,
    this.headerGap = 12,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [header, Gap(headerGap), child],
      ),
    );
  }
}
