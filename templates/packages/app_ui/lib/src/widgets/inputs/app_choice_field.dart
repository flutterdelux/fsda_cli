import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppChoiceField<T> extends StatelessWidget {
  final List<T> entries;
  final String Function(T value) label;
  final bool Function(T value) isSelected;
  final void Function(T value, bool selected) onSelected;
  final EdgeInsetsGeometry? Function(T value, int index)? margin;
  final bool withScroll;
  final double spacing;
  final double runSpacing;
  final bool showCheckmark;

  const AppChoiceField({
    super.key,
    required this.entries,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.margin,
    this.withScroll = false,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final children = List.generate(entries.length, (index) {
      final entry = entries[index];
      final isItemActive = isSelected(entry);
      return Padding(
        padding: margin?.call(entry, index) ?? EdgeInsets.zero,
        child: ChoiceChip(
          checkmarkColor: colorScheme.onSecondary,
          showCheckmark: showCheckmark,
          label: Text(
            label(entry),
            style: TextStyle(
              color: isItemActive
                  ? colorScheme.onSecondary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          selected: isItemActive,
          onSelected: (isSelected) => onSelected(entry, isSelected),
          color: WidgetStateMapper({
            WidgetState.selected: colorScheme.secondary,
            WidgetState.any: colorScheme.surfaceContainer,
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: isItemActive
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
        ),
      );
    });

    if (withScroll) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: children,
          ),
        ),
      );
    }
    return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
  }
}
