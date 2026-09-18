import 'package:mason/mason.dart';

class SliceManifestRenderService {
  const SliceManifestRenderService();

  String renderSequenceManifest({
    required String template,
    required Map<String, dynamic> vars,
  }) {
    final isList = vars['is_list'] == true;
    template = _renderBoolSection(
      source: template,
      sectionName: 'is_list',
      value: isList,
      inverted: false,
    );
    template = _renderBoolSection(
      source: template,
      sectionName: 'is_list',
      value: isList,
      inverted: true,
    );

    template = template.replaceAllMapped(
      RegExp(
        r'\{\{#(paramCase|snakeCase|camelCase|pascalCase)\}\}\s*\{\{([A-Za-z_]\w*)\}\}\s*\{\{/\1\}\}',
      ),
      (match) {
        final transform = match.group(1)!;
        final key = match.group(2)!;
        final raw = vars[key];
        if (raw == null) {
          return '';
        }

        return _applyCaseTransform(raw.toString(), transform);
      },
    );

    template = template.replaceAllMapped(
      RegExp(
        r'\{\{\s*([A-Za-z_]\w*)\.(snakeCase|camelCase|pascalCase|paramCase)\(\)\s*\}\}',
      ),
      (match) {
        final key = match.group(1)!;
        final transform = match.group(2)!;
        final raw = vars[key];
        if (raw == null) {
          return '';
        }

        return _applyCaseTransform(raw.toString(), transform);
      },
    );

    template = template.replaceAllMapped(
      RegExp(r'\{\{\s*([A-Za-z_]\w*)\s*\}\}'),
      (match) {
        final key = match.group(1)!;
        final raw = vars[key];
        return raw?.toString() ?? '';
      },
    );

    if (RegExp(r'\{\{[^}]+\}\}').hasMatch(template)) {
      throw const FormatException(
        'Unresolved template placeholders found in sequence.yaml after render.',
      );
    }

    return template;
  }

  String _renderBoolSection({
    required String source,
    required String sectionName,
    required bool value,
    required bool inverted,
  }) {
    final marker = inverted ? '^' : '#';
    final pattern = RegExp(
      '\\{\\{$marker${RegExp.escape(sectionName)}\\}\\}([\\s\\S]*?)\\{\\{/${RegExp.escape(sectionName)}\\}\\}',
    );

    return source.replaceAllMapped(pattern, (match) {
      final body = match.group(1) ?? '';
      final shouldKeep = inverted ? !value : value;
      return shouldKeep ? body : '';
    });
  }

  String _applyCaseTransform(String value, String transform) {
    return switch (transform) {
      'snakeCase' => value.snakeCase,
      'camelCase' => value.camelCase,
      'pascalCase' => value.pascalCase,
      'paramCase' => value.snakeCase.replaceAll('_', '-'),
      _ => value,
    };
  }
}
