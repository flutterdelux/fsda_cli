import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';

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
  

  void _onInputChanged() {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        
      ],
    );
  }
}
