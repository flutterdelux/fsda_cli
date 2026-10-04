import '../../enums/form_input_type.dart';
import '../../models/generation/input_typed_field.dart';
import 'typed_prop_parser_service.dart';

class InputTypedFieldParserService {
  final TypedPropParserService typedPropParser;

  const InputTypedFieldParserService({TypedPropParserService? typedPropParser})
    : typedPropParser = typedPropParser ?? const TypedPropParserService();

  List<InputTypedField> parse({
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

    final parsed = <InputTypedField>[];
    final seenNames = <String>{};

    for (final segment in segments) {
      final token = _normalizeToken(segment);
      if (token.isEmpty) {
        continue;
      }

      final parts = _splitByTopLevelColon(token);
      if (parts.length != 3) {
        throw FormatException(
          'Invalid field token "$token". Use input_type:value_type:field_name.',
        );
      }

      final inputTypeToken = parts[0].trim();
      final valueTypeToken = parts[1].trim();
      final fieldNameToken = parts[2].trim();

      if (inputTypeToken.isEmpty ||
          valueTypeToken.isEmpty ||
          fieldNameToken.isEmpty) {
        throw FormatException(
          'Invalid field token "$token". Use input_type:value_type:field_name.',
        );
      }

      if (fieldNameToken.contains('=')) {
        throw FormatException(
          'Default value is not supported for "$fieldNameToken". Use input_type:value_type:field_name.',
        );
      }

      final inputType = FormInputType.tryParse(inputTypeToken);
      if (inputType == null) {
        throw FormatException(
          'Invalid input_type "$inputTypeToken" in token "$token". Use fixed snake_case values: text, number, selector, selector_list, text_area, qty, dropdown, dropdown_enum, image, switch, password.',
        );
      }

      final props = typedPropParser.parse(
        optionValues: <String>['$valueTypeToken:$fieldNameToken'],
      );
      if (props.length != 1) {
        throw FormatException(
          'Invalid property declaration in token "$token".',
        );
      }

      final prop = props.first;
      if (!seenNames.add(prop.name)) {
        throw FormatException('Duplicate property name "${prop.name}".');
      }

      parsed.add(InputTypedField(prop: prop, inputType: inputType));
    }

    if (parsed.isEmpty) {
      throw const FormatException('Missing required option(s): --fields');
    }

    return parsed;
  }

  List<String> _splitByTopLevelColon(String value) {
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

    for (var i = 0; i < source.length; i += 1) {
      final char = source[i];

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

      final isTopLevelColon =
          char == ':' &&
          !inSingleQuote &&
          !inDoubleQuote &&
          angleDepth == 0 &&
          roundDepth == 0 &&
          squareDepth == 0 &&
          curlyDepth == 0;

      if (isTopLevelColon) {
        results.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    results.add(buffer.toString());

    return results;
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

    for (var i = 0; i < source.length; i += 1) {
      final char = source[i];

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
