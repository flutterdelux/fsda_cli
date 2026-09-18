import 'package:mason/mason.dart';

String buildPasswordInputTemplate({
  required String moduleName,
  required String featureName,
  required String fieldName,
}) {
  final featurePascal = featureName.pascalCase;
  final fieldPascal = fieldName.pascalCase;
  final l10nKey = '${featureName.camelCase}Field$fieldPascal';
  final className = '$featurePascal${fieldPascal}Field';
  final stateClassName = '_${className}State';

  return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class $className extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String value)? onSubmitted;

  const $className({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  State<$className> createState() => $stateClassName();
}

class $stateClassName extends State<$className> {
  late final ValueNotifier<bool> _obscureTextNotifier;

  @override
  void initState() {
    super.initState();
    _obscureTextNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _obscureTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ${moduleName.pascalCase}Localizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureTextNotifier,
      builder: (_, obscure, _) {
        return AppTextField(
          controller: widget.controller,
          hintText: l10n.${l10nKey}Hint,
          obscureText: obscure,
          prefix: const Icon(Icons.lock_outline),
          suffix: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () {
              _obscureTextNotifier.value = !_obscureTextNotifier.value;
            },
          ),
          onSubmitted: widget.onSubmitted,
        );
      },
    );
  }
}
''';
}
