import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const {{feature.pascalCase()}}DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.{{feature.camelCase()}}FieldDescriptionLabel),
      content: AppTextField(
        controller: controller,
        hintText: l10n.{{feature.camelCase()}}FieldDescriptionHint,
        minLines: 5,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
}
