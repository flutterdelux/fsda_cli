import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final List<DropdownMenuEntry<T>> menuEntries;
  final T? initialSelection;
  final String? hintText;
  final Widget? prefix;
  final void Function(T? value)? onSelected;

  const AppDropdownField({
    super.key,
    required this.menuEntries,
    this.initialSelection,
    this.hintText,
    this.prefix,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DropdownMenuFormField<T>(
      initialSelection: initialSelection,
      dropdownMenuEntries: menuEntries,
      expandedInsets: EdgeInsets.zero,
      hintText: hintText,
      leadingIcon: prefix,
      trailingIcon: const Icon(Icons.keyboard_arrow_down),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up),
      textStyle: textTheme.bodyLarge,
      onSelected: onSelected,
    );
  }
}
