import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/{{feature.snakeCase()}}_entity.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Content extends StatelessWidget {
  static const height = 280.0;

  final {{feature.pascalCase()}}Entity {{feature.camelCase()}};
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Content({
    super.key,
    required this.{{feature.camelCase()}},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
      ],
    );
  }
}
