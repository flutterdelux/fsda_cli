import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final bool showDividers;
  final double dividerSpace;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppCard({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.showDividers = true,
    this.dividerSpace = 0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  bool get isVertical => direction == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    if (showDividers) {
      for (var i = 0; i < children.length; i++) {
        items.add(children[i]);
        if (i < children.length - 1) {
          items.add(
            isVertical
                ? Divider(height: dividerSpace)
                : VerticalDivider(width: dividerSpace),
          );
        }
      }
    } else {
      items.addAll(children);
    }

    final content = Flex(
      mainAxisSize: MainAxisSize.min,
      direction: direction,
      children: items,
    );

    final contentWithIntrinsic = isVertical
        ? content
        : IntrinsicHeight(child: content);

    final contentWithPadding = Padding(
      padding: padding,
      child: contentWithIntrinsic,
    );

    final contentWithCard = Card(
      margin: EdgeInsets.zero,
      child: contentWithPadding,
    );

    return Padding(padding: margin, child: contentWithCard);
  }
}
