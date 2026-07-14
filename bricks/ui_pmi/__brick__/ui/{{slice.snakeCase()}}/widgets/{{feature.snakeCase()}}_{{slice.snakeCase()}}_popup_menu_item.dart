import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}PopupMenuItem extends PopupMenuItem {
  static const valueKey = '{{feature.snakeCase()}}_{{slice.snakeCase()}}';

  const {{feature.pascalCase()}}{{slice.pascalCase()}}PopupMenuItem({super.key, super.onTap})
    : super(value: valueKey, child: const _Child());
}

class _Child extends StatelessWidget {
  const _Child();

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return Row(
      children: [
        const Icon(Icons.circle, size: 20),
        AppGap.sm,
        Text(l10n.{{feature.camelCase()}}{{slice.pascalCase()}}PopupMenuItem),
      ],
    );
  }
}