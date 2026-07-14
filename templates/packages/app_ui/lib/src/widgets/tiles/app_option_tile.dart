import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

class AppOptionTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? leadingIcon;
  final IconData selectedIcon;
  final bool isSelected;

  const AppOptionTile({
    super.key,
    required this.title,
    this.selectedIcon = Icons.radio_button_checked,
    this.leadingIcon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      leading: leadingIcon,
      title: Text(
        title,
        style: isSelected ? textTheme.titleMedium : textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelected
          ? Icon(selectedIcon, color: colorScheme.primary)
          : null,
    );
  }
}
