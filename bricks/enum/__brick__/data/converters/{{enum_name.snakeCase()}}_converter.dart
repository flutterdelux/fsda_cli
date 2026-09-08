import 'package:json_annotation/json_annotation.dart';

import '../../domain/enums/{{enum_name.snakeCase()}}.dart';

class {{enum_class}}Converter extends JsonConverter<{{enum_class}}, String> {
  const {{enum_class}}Converter();

  @override
  {{enum_class}} fromJson(String json) {
    return switch (json) {
{{{from_json_cases}}}
      _ => throw ArgumentError('Invalid {{invalid_enum_label}}: $json'),
    };
  }

  @override
  String toJson({{enum_class}} object) {
    return switch (object) {
{{{to_json_cases}}}
    };
  }
}
