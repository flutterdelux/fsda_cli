import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}View extends StatelessWidget {
  final Widget content;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}View({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.{{feature.camelCase()}}{{slice.pascalCase()}}Title)),
      body: content,
    );
  }
}
