import 'package:flutter/material.dart';

import '../../extensions/color_scheme_x.dart';

class AppClickableText extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const AppClickableText({super.key, required this.text, required this.onTap});

  @override
  State<AppClickableText> createState() => _AppClickableTextState();
}

class _AppClickableTextState extends State<AppClickableText> {
  late final ValueNotifier<bool> _isPressedNotifier;

  @override
  void initState() {
    super.initState();
    _isPressedNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _isPressedNotifier.value = true,
      onTapUp: (_) => _isPressedNotifier.value = false,
      onTapCancel: () => _isPressedNotifier.value = false,
      onTap: widget.onTap,

      child: ValueListenableBuilder(
        valueListenable: _isPressedNotifier,
        builder: (_, isPressed, _) {
          final style = textTheme.titleSmall?.copyWith(
            color: isPressed
                ? colorScheme.onSurface
                : colorScheme.onSurfaceMedium,
          );

          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: style!,
            child: Text(widget.text),
          );
        },
      ),
    );
  }
}
