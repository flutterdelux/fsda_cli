import 'package:freezed_annotation/freezed_annotation.dart';

import '../dtos/{{feature.snakeCase()}}_dto.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_response.freezed.dart';
part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_response.g.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}Response with _${{feature.pascalCase()}}{{slice.pascalCase()}}Response {
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Response._();

  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}Response({
    required String status,
    required String message,
    @JsonKey(fromJson: _{{feature.camelCase()}}FromJson) {{feature.pascalCase()}}Dto? data,
    String? code,
    List<String>? errors,
  }) = _{{feature.pascalCase()}}{{slice.pascalCase()}}Response;

  factory {{feature.pascalCase()}}{{slice.pascalCase()}}Response.fromJson(Map<String, Object?> json) =>
      _${{feature.pascalCase()}}{{slice.pascalCase()}}ResponseFromJson(json);
}

{{feature.pascalCase()}}Dto? _{{feature.camelCase()}}FromJson(Object? json) {
  if (json is Map) {
    return {{feature.pascalCase()}}Dto.fromJson(json as Map<String, dynamic>);
  }
  return null;
}
