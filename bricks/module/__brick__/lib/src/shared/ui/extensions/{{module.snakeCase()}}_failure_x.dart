import 'package:flutter/material.dart';

import '../../../generated/{{module.snakeCase()}}_localizations.dart';
import '../../domain/errors/{{module.snakeCase()}}_failure.dart';

extension {{module.pascalCase()}}FailureX on {{module.pascalCase()}}Failure {
  String localize(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return switch (this) {
      {{module.pascalCase()}}Failure.{{module.camelCase()}}NotFound => l10n.failure{{module.pascalCase()}}NotFound,
    };
  }
}
