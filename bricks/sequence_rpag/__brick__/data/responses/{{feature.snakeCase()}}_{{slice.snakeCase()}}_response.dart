import 'package:freezed_annotation/freezed_annotation.dart';

import '../dtos/{{feature.snakeCase()}}_dto.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_response.freezed.dart';
part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_response.g.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}Response with _${{feature.pascalCase()}}{{slice.pascalCase()}}Response {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}Response({
    required String status,
    required String message,
    Map<String, dynamic>? meta,
    @JsonKey(fromJson: _fromJson) List<{{feature.pascalCase()}}Dto>? data,
    String? code,
    List<String>? errors,
  }) = _{{feature.pascalCase()}}{{slice.pascalCase()}}Response;

  factory {{feature.pascalCase()}}{{slice.pascalCase()}}Response.fromJson(Map<String, dynamic> json) =>
      _${{feature.pascalCase()}}{{slice.pascalCase()}}ResponseFromJson(json);
}

List<{{feature.pascalCase()}}Dto>? _fromJson(Object? json) {
  if (json is List) {
    return json
        .map((item) => {{feature.pascalCase()}}Dto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return null;
}
