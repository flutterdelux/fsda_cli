import 'package:mason/mason.dart';

import '../../constants/cli_rules.dart';
import '../../models/generation/typed_prop.dart';

class TypedPropParserService {
  const TypedPropParserService();

  static final _validTypePattern = RegExp(
    r'^[A-Za-z_][A-Za-z0-9_]*(?:<[^<>]+>)?\??$',
  );
  static final _validNamePattern = RegExp(CliRules.sliceNamePattern);

  List<TypedProp> parse({
    required List<String> optionValues,
    List<String> trailingValues = const <String>[],
  }) {
    final segments = <String>[];
    for (final value in optionValues) {
      segments.addAll(_splitByComma(value));
    }
    for (final value in trailingValues) {
      segments.addAll(_splitByComma(value));
    }

    final parsed = <TypedProp>[];
    final seenNames = <String>{};
    final seenCamelNames = <String>{};

    for (final segment in segments) {
      final token = _normalizeToken(segment);
      if (token.isEmpty) {
        continue;
      }

      final colonIndex = token.indexOf(':');
      if (colonIndex <= 0 || colonIndex == token.length - 1) {
        throw FormatException(
          'Invalid property token "$token". Use type:name or type:name=default.',
        );
      }

      final rawType = token.substring(0, colonIndex).trim();
      final right = token.substring(colonIndex + 1).trim();
      if (rawType.isEmpty || right.isEmpty) {
        throw FormatException(
          'Invalid property token "$token". Use type:name or type:name=default.',
        );
      }

      final eqIndex = right.indexOf('=');
      final rawName = (eqIndex == -1 ? right : right.substring(0, eqIndex))
          .trim();
      final rawDefault = eqIndex == -1
          ? null
          : right.substring(eqIndex + 1).trim();

      if (!_validTypePattern.hasMatch(_normalizeType(rawType))) {
        throw FormatException(
          'Invalid property type "$rawType" in token "$token".',
        );
      }

      if (!_validNamePattern.hasMatch(rawName)) {
        throw FormatException(
          'Invalid property name "$rawName" in token "$token". Use snake_case for property names.',
        );
      }

      if (rawDefault != null && rawDefault.isEmpty) {
        throw FormatException(
          'Default value is empty for property "$rawName" in token "$token".',
        );
      }

      if (!seenNames.add(rawName)) {
        throw FormatException('Duplicate property name "$rawName".');
      }

      final normalizedPropertyName = rawName.camelCase;
      if (!seenCamelNames.add(normalizedPropertyName)) {
        throw FormatException(
          'Duplicate property name after camelCase normalization: "$normalizedPropertyName".',
        );
      }

      parsed.add(
        TypedProp(
          type: _normalizeType(rawType),
          name: rawName,
          defaultValue: rawDefault,
        ),
      );
    }

    if (parsed.isEmpty) {
      throw const FormatException('Missing required option(s): --props');
    }

    return parsed;
  }

  String _normalizeType(String rawType) {
    return rawType.replaceAll(' ', '');
  }

  String _normalizeToken(String value) {
    return value
        .replaceFirst(RegExp(r'^,+'), '')
        .replaceFirst(RegExp(r',+$'), '')
        .trim();
  }

  List<String> _splitByComma(String value) {
    final source = value.trim();
    if (source.isEmpty) {
      return const <String>[];
    }

    final results = <String>[];
    final buffer = StringBuffer();
    var angleDepth = 0;
    var roundDepth = 0;
    var squareDepth = 0;
    var curlyDepth = 0;
    var inSingleQuote = false;
    var inDoubleQuote = false;

    for (final rune in source.runes) {
      final char = String.fromCharCode(rune);

      if (char == "'" && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
      } else if (char == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
      } else if (!inSingleQuote && !inDoubleQuote) {
        if (char == '<') {
          angleDepth += 1;
        } else if (char == '>' && angleDepth > 0) {
          angleDepth -= 1;
        } else if (char == '(') {
          roundDepth += 1;
        } else if (char == ')' && roundDepth > 0) {
          roundDepth -= 1;
        } else if (char == '[') {
          squareDepth += 1;
        } else if (char == ']' && squareDepth > 0) {
          squareDepth -= 1;
        } else if (char == '{') {
          curlyDepth += 1;
        } else if (char == '}' && curlyDepth > 0) {
          curlyDepth -= 1;
        }
      }

      final canSplit =
          char == ',' &&
          !inSingleQuote &&
          !inDoubleQuote &&
          angleDepth == 0 &&
          roundDepth == 0 &&
          squareDepth == 0 &&
          curlyDepth == 0;

      if (canSplit) {
        results.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      results.add(buffer.toString());
    }

    return results;
  }
}
