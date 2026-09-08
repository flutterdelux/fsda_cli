import 'package:flutter/material.dart';

import '../../../../../generated/{{module.snakeCase()}}_localizations.dart';
import '../../../domain/enums/{{enum_name.snakeCase()}}.dart';

extension {{enum_class}}X on {{enum_class}} {
  String localize(BuildContext context) {
    final l10n = {{module.pascalCase()}}Localizations.of(context)!;
    return switch (this) {
{{{localize_cases}}}
    };
  }
}
