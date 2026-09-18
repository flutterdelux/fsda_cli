import 'package:freezed_annotation/freezed_annotation.dart';
import '../dtos/{{model.snakeCase()}}_dto.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_response.freezed.dart';
part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_response.g.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}Response with _${{feature.pascalCase()}}{{slice.pascalCase()}}Response {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}Response({
    required String message,
    {{#is_list}}@JsonKey(fromJson: _{{model.camelCase()}}ListFromJson) List<{{model.pascalCase()}}Dto>? data,{{/is_list}}
    {{^is_list}}@JsonKey(fromJson: _{{model.camelCase()}}FromJson) {{model.pascalCase()}}Dto? data,{{/is_list}}
    String? code,
    List<String>? errors,
  }) = _{{feature.pascalCase()}}{{slice.pascalCase()}}Response;

  factory {{feature.pascalCase()}}{{slice.pascalCase()}}Response.fromJson(Map<String, dynamic> json) =>
      _${{feature.pascalCase()}}{{slice.pascalCase()}}ResponseFromJson(json);
}

{{#is_list}}List<{{model.pascalCase()}}Dto>? _{{model.camelCase()}}ListFromJson(Object? json) {
  if (json is List) {
    return json
        .map((item) => {{model.pascalCase()}}Dto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return null;
}{{/is_list}}
{{^is_list}}{{model.pascalCase()}}Dto? _{{model.camelCase()}}FromJson(Object? json) {
  if (json is Map) {
    return {{model.pascalCase()}}Dto.fromJson(json as Map<String, dynamic>);
  }
  return null;
}{{/is_list}}