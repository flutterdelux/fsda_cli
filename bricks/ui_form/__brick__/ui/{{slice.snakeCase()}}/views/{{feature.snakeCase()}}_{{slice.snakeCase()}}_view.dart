
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}View extends StatelessWidget {
  /// Use `{{feature.pascalCase()}}{{slice.pascalCase()}}Form`
  final Widget form;

  /// Use `{{feature.pascalCase()}}{{slice.pascalCase()}}Button`
  final Widget submitButton;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}View({
    super.key,
    required this.form,
    required this.submitButton,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.{{feature.camelCase()}}{{slice.pascalCase()}}Title)),
      body: form,
      bottomNavigationBar: AppBottomContainer(child: submitButton),
    );
  }
}
