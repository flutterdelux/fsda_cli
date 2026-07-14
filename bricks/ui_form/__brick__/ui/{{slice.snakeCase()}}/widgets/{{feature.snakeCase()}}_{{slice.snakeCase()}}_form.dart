import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../../shared/widgets/{{feature.snakeCase()}}_description_field.dart';
import '../../shared/widgets/{{feature.snakeCase()}}_title_field.dart';

import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Form extends StatefulWidget {
  final void Function(
    BuildContext context,
    {{feature.pascalCase()}}{{slice.pascalCase()}}Param? param,
    String? invalidMessage,
  )
  onListen;
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Form({super.key, required this.onListen});

  @override
  State<{{feature.pascalCase()}}{{slice.pascalCase()}}Form> createState() => _{{feature.pascalCase()}}{{slice.pascalCase()}}FormState();
}

class _{{feature.pascalCase()}}{{slice.pascalCase()}}FormState extends State<{{feature.pascalCase()}}{{slice.pascalCase()}}Form> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  void _onInputChanged() {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;

    final title = _titleController.text;
    if (title.isEmpty) {
      widget.onListen(context, null, l10n.{{feature.camelCase()}}FieldTitleInvalidEmpty);
      return;
    }

    final description = _descriptionController.text;
    if (description.isEmpty) {
      widget.onListen(context, null, l10n.{{feature.camelCase()}}FieldDescriptionInvalidEmpty);
      return;
    }

    final param = {{feature.pascalCase()}}{{slice.pascalCase()}}Param(title: title, description: description);
    widget.onListen(context, param, null);
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController()..addListener(_onInputChanged);
    _descriptionController = TextEditingController()
      ..addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onInputChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onInputChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        {{feature.pascalCase()}}TitleField(controller: _titleController),
        AppGap.lg,
        {{feature.pascalCase()}}DescriptionField(controller: _descriptionController),
      ],
    );
  }
}
